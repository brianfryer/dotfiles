#!/usr/bin/env python3
"""Compare configured dotfile tools against privacy-preserving command usage.

This script is deliberately non-mutating: it reads this repository plus local
shell-history stores, aggregates command *names*, and prints a report. It never
prints raw command lines by default because shell history often contains
credentials, tokens, database URLs, file names, and other context that should not
be copied into a repo or pasted into chat.

The output should be treated as evidence, not as an automatic delete list:

* CLI commands, aliases, and shell functions are good candidates for
  history-based review because they normally appear as the first token of a
  shell command.
* GUI applications installed through Homebrew casks are weak candidates for
  history-based review because a person can use Slack, Chrome, Spotify, etc.
  every day without ever typing the cask token in a terminal.
* Bootstrap-only tools can be unseen in history but still worth keeping if they
  are required to make a fresh machine install reproducible.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import sqlite3
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


REPO_DEFAULT = Path(__file__).resolve().parents[1]


# Homebrew formula names are not always the command names that appear in shell
# history. These hints let the report count the command a person actually types
# while still pointing back to the formula that installs it.
COMMAND_NAME_HINTS = {
    "coreutils": ["gls", "gcat", "gdate", "gdu", "greadlink"],
    "findutils": ["gfind", "gxargs", "glocate", "gupdatedb"],
    "gnu-sed": ["gsed"],
    "imagemagick": ["magick", "convert"],
    "the_silver_searcher": ["ag"],
}


# These tokens often appear as the first word of pasted code blocks, heredocs,
# or shell grammar. They are not useful evidence for whether dotfile-managed
# commands are in active use.
NON_COMMAND_TOKENS = {
    "case",
    "class",
    "const",
    "do",
    "done",
    "else",
    "EOF",
    "export",
    "fi",
    "for",
    "function",
    "if",
    "import",
    "let",
    "return",
    "then",
    "var",
    "while",
    "//",
}


@dataclass(frozen=True)
class ConfiguredItem:
    """A command-like thing declared by this dotfiles repo.

    `name` is the executable, alias, function, formula, or cask token we can
    compare against history. `kind` preserves where it came from so the report
    can avoid over-interpreting casks as unused CLI tools.
    """

    name: str
    kind: str
    path: str
    line: int
    detail: str


@dataclass
class CommandUse:
    """Aggregated command usage without raw arguments."""

    count: int = 0
    last_seen_rank: int = 0
    score: float = 0.0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit configured dotfile commands against shell-history usage."
    )
    parser.add_argument(
        "--repo",
        type=Path,
        default=REPO_DEFAULT,
        help="Dotfiles repository root. Defaults to this script's parent repo.",
    )
    parser.add_argument(
        "--format",
        choices=("markdown", "json"),
        default="markdown",
        help="Output format. Markdown is intended for docs/usage-audit.md.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=40,
        help="Number of rows to show in each report table.",
    )
    return parser.parse_args()


def strip_zsh_extended_history(line: str) -> str:
    """Return the command part from zsh EXTENDED_HISTORY lines when present."""

    # zsh extended history looks like:
    #   : 1717600000:0;git status --short
    # Only the text after the first semicolon is the command. Keeping the prefix
    # would make ":" look like the command name and destroy the usage signal.
    if line.startswith(": ") and ";" in line[:80]:
        return line.split(";", 1)[1]
    return line


def command_name_from_line(raw_line: str) -> str | None:
    """Extract a command name from one history line without returning arguments."""

    line = strip_zsh_extended_history(raw_line.strip())
    if not line or line.startswith("#"):
        return None

    try:
        parts = shlex.split(line, posix=True)
    except ValueError:
        # Broken quoting is common in shell history. A whitespace split is good
        # enough because we only need the first command-like token.
        parts = line.split()

    if not parts:
        return None

    index = 0

    # Skip common wrappers that do not represent the actual command being used.
    wrappers = {"sudo", "command", "noglob", "time"}
    if parts[index] in wrappers and len(parts) > index + 1:
        index += 1

    # `env FOO=bar command` should count as `command`, not `env`.
    if parts[index] == "env":
        index += 1
        while index < len(parts) and "=" in parts[index] and not parts[index].startswith("-"):
            index += 1
        if index >= len(parts):
            return None

    command = parts[index]

    # Filter multiline paste artifacts and code fragments. These show up when a
    # shell session receives pasted HTML/CSS/JS or heredoc bodies. They are not
    # reliable evidence for command usage.
    if command.startswith("-"):
        return None
    if command in NON_COMMAND_TOKENS:
        return None
    if len(command) > 48:
        return None
    if command.startswith(("<", "</", "<!--", "@")):
        return None
    if command.endswith((":", "{", "}")):
        return None
    if not re.match(r"^[A-Za-z0-9_./+-]+$", command):
        return None

    # Normalize explicit relative paths so `./script` and `script` can be
    # compared more naturally in the report.
    return command.removeprefix("./")


def read_shell_history() -> Iterable[tuple[str, int]]:
    """Yield command lines from shell history files with a monotonic rank."""

    paths = [Path.home() / ".zsh_history", Path.home() / ".bash_history"]
    rank = 0
    for path in paths:
        if not path.exists():
            continue
        for line in path.read_text(errors="ignore").splitlines():
            rank += 1
            yield line, rank


def atuin_history_paths() -> list[Path]:
    """Return likely Atuin SQLite history locations."""

    candidates = [
        Path.home() / ".local/share/atuin/history.db",
        Path.home() / ".config/atuin/history.db",
    ]

    data_home = os.environ.get("XDG_DATA_HOME")
    if data_home:
        candidates.insert(0, Path(data_home) / "atuin/history.db")

    return [path for path in candidates if path.exists()]


def read_atuin_history() -> Iterable[tuple[str, int]]:
    """Yield command lines from Atuin when available.

    Atuin stores structured history in SQLite. The exact schema can vary across
    versions, so this code introspects columns and only relies on a `command`
    column plus either `timestamp`, `created_at`, or SQLite row order.
    """

    for db_path in atuin_history_paths():
        with sqlite3.connect(db_path) as connection:
            columns = {
                row[1] for row in connection.execute("PRAGMA table_info(history)").fetchall()
            }
            if "command" not in columns:
                continue

            order_column = "timestamp" if "timestamp" in columns else "created_at"
            if order_column in columns:
                query = f"SELECT command FROM history ORDER BY {order_column}, rowid"
            else:
                query = "SELECT command FROM history ORDER BY rowid"

            for rank, (command,) in enumerate(connection.execute(query), start=1):
                yield command, rank


def aggregate_usage() -> tuple[dict[str, CommandUse], str, int]:
    """Aggregate command names from Atuin when present, otherwise shell history."""

    source_name = "atuin"
    rows = list(read_atuin_history())
    if not rows:
        source_name = "shell_history"
        rows = list(read_shell_history())

    counts: Counter[str] = Counter()
    last_seen: dict[str, int] = {}
    for raw_line, rank in rows:
        command = command_name_from_line(raw_line)
        if not command:
            continue
        counts[command] += 1
        last_seen[command] = rank

    total_ranks = max((rank for _, rank in rows), default=0)
    max_count = max(counts.values(), default=1)
    usage: dict[str, CommandUse] = {}
    for command, count in counts.items():
        recency = (last_seen[command] / total_ranks) if total_ranks else 0
        frequency = count / max_count
        usage[command] = CommandUse(
            count=count,
            last_seen_rank=last_seen[command],
            score=round((frequency * 0.65) + (recency * 0.35), 4),
        )

    return usage, source_name, len(rows)


def iter_repo_lines(repo: Path, relative_paths: Iterable[str]) -> Iterable[tuple[str, int, str]]:
    for relative_path in relative_paths:
        path = repo / relative_path
        if not path.exists():
            continue
        for line_number, line in enumerate(path.read_text(errors="ignore").splitlines(), start=1):
            yield relative_path, line_number, line


def configured_items(repo: Path) -> list[ConfiguredItem]:
    """Extract command-like declarations from known dotfiles surfaces."""

    items: list[ConfiguredItem] = []

    for path, line_number, line in iter_repo_lines(repo, ["brew.sh", "cask.sh", "Brewfile"]):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        # Legacy shell scripts:
        #   brew install git
        #   brew reinstall gnu-sed --default-names
        #   brew cask install google-chrome
        match = re.match(r"brew\s+(install|reinstall)\s+([A-Za-z0-9_./@+-]+)", stripped)
        if match:
            items.append(
                ConfiguredItem(match.group(2), "formula", path, line_number, stripped)
            )
            continue

        match = re.match(r"brew\s+cask\s+install\s+([A-Za-z0-9_.@+-]+)", stripped)
        if match:
            items.append(ConfiguredItem(match.group(1), "cask", path, line_number, stripped))
            continue

        # Future Brewfile support:
        #   brew "git"
        #   cask "google-chrome"
        match = re.match(r'(brew|cask|tap)\s+["\']([^"\']+)["\']', stripped)
        if match:
            kind = "formula" if match.group(1) == "brew" else match.group(1)
            items.append(ConfiguredItem(match.group(2), kind, path, line_number, stripped))

    for path, line_number, line in iter_repo_lines(
        repo, [".aliases", ".functions", ".zshrc", ".bash_profile", ".exports"]
    ):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        match = re.match(r"alias\s+(-{0,2}[A-Za-z0-9_.+-]+)=['\"]?([^'\"]+)", stripped)
        if match:
            alias_name = match.group(1)
            if alias_name == "--":
                continue
            items.append(ConfiguredItem(alias_name, "alias", path, line_number, stripped))
            continue

        match = re.match(r"(?:function\s+)?([A-Za-z_][A-Za-z0-9_-]*)\s*\(\)", stripped)
        if match:
            items.append(ConfiguredItem(match.group(1), "function", path, line_number, stripped))
            continue

        # Shell integrations often configure tools without declaring aliases or
        # functions. Capture the command a user would type so current tools like
        # mise, z, Bun, and gcloud are represented in the report.
        integration_patterns = [
            (r"\bbrew\s+shellenv\b", "brew"),
            (r"\bpyenv\s+init\b", "pyenv"),
            (r"\bmise\s+activate\b", "mise"),
            (r"\bz/z\.sh\b", "z"),
            (r"\.bun/bin", "bun"),
            (r"google-cloud-sdk", "gcloud"),
            (r"\bgdircolors\b", "gdircolors"),
        ]
        for pattern, command_name in integration_patterns:
            if re.search(pattern, stripped):
                items.append(
                    ConfiguredItem(command_name, "shell_integration", path, line_number, stripped)
                )
                break

    # Deduplicate exact declarations while preserving the first source reference.
    seen: set[tuple[str, str, str, int]] = set()
    unique: list[ConfiguredItem] = []
    for item in items:
        if item.kind == "shell_integration":
            key = (item.name, item.kind, "", 0)
        else:
            key = (item.name, item.kind, item.path, item.line)
        if key in seen:
            continue
        seen.add(key)
        unique.append(item)

    return unique


def obsolete_patterns(repo: Path) -> list[tuple[str, int, str, str]]:
    """Find syntax or install references that are obsolete independent of usage."""

    patterns = [
        ("legacy_brew_cask", re.compile(r"\bbrew\s+cask\b")),
        ("old_cask_tap", re.compile(r"\bcaskroom/|homebrew/cask-drivers")),
        ("old_homebrew_tap", re.compile(r"\bhomebrew/versions\b")),
        ("old_homebrew_installer", re.compile(r"raw\.githubusercontent\.com/Homebrew/install/master")),
        ("easy_install", re.compile(r"\beasy_install\b")),
        ("bower", re.compile(r"\bbower\b")),
        ("rvm_or_n_installer", re.compile(r"get\.rvm\.io|git\.io/n-install")),
        ("sublime_text_3", re.compile(r"Sublime Text 3|sublime-text-3")),
    ]

    relative_paths = [
        "README.md",
        "setup-a-new-machine.sh",
        "brew.sh",
        "cask.sh",
        ".aliases",
        ".functions",
        ".zshrc",
        ".bash_profile",
    ]
    matches: list[tuple[str, int, str, str]] = []
    for path, line_number, line in iter_repo_lines(repo, relative_paths):
        for label, pattern in patterns:
            if pattern.search(line):
                matches.append((path, line_number, label, line.strip()))
    return matches


def source_link(item: ConfiguredItem) -> str:
    return f"{item.path}:{item.line}"


def usage_for_item(item: ConfiguredItem, usage: dict[str, CommandUse]) -> CommandUse:
    """Return direct usage plus known command-name hints for a configured item."""

    names = [item.name, *COMMAND_NAME_HINTS.get(item.name, [])]
    count = 0
    last_seen_rank = 0
    score = 0.0

    for name in names:
        command_use = usage.get(name)
        if not command_use:
            continue
        count += command_use.count
        last_seen_rank = max(last_seen_rank, command_use.last_seen_rank)
        score = max(score, command_use.score)

    return CommandUse(count=count, last_seen_rank=last_seen_rank, score=score)


def item_rows(
    items: Iterable[ConfiguredItem],
    usage: dict[str, CommandUse],
    limit: int,
) -> list[tuple[ConfiguredItem, CommandUse]]:
    rows = [(item, usage_for_item(item, usage)) for item in items]
    rows.sort(key=lambda row: (row[1].count, row[1].score, row[1].last_seen_rank), reverse=True)
    return rows[:limit]


def render_markdown(
    repo: Path,
    usage: dict[str, CommandUse],
    usage_source: str,
    raw_row_count: int,
    items: list[ConfiguredItem],
    obsolete: list[tuple[str, int, str, str]],
    limit: int,
) -> str:
    formula_or_shell = [item for item in items if item.kind != "cask"]
    casks = [item for item in items if item.kind == "cask"]
    active = [item for item in formula_or_shell if usage_for_item(item, usage).count > 0]
    unseen = [item for item in formula_or_shell if usage_for_item(item, usage).count == 0]

    top_commands = sorted(
        usage.items(),
        key=lambda pair: (pair[1].count, pair[1].score, pair[1].last_seen_rank),
        reverse=True,
    )[:limit]

    lines = [
        "# Dotfiles Usage Audit",
        "",
        "This report compares command-like things configured by this repo against",
        "local command-history usage. It intentionally reports command names only,",
        "not raw command lines or arguments.",
        "",
        "## Summary",
        "",
        f"- Repository: `{repo}`",
        f"- Usage source: `{usage_source}`",
        f"- Raw history rows scanned: `{raw_row_count}`",
        f"- Configured command-like items found: `{len(items)}`",
        f"- Active configured CLI items: `{len(active)}`",
        f"- Configured CLI items unseen in history: `{len(unseen)}`",
        f"- Configured GUI casks: `{len(casks)}`",
        f"- Obsolete syntax references found: `{len(obsolete)}`",
        "",
        "## Privacy Rules",
        "",
        "- Do not paste raw shell-history lines into this repo.",
        "- Treat command-name counts as evidence, not proof.",
        "- Formulae may match known command aliases, such as `imagemagick` -> `magick`.",
        "- Review casks manually; GUI app usage usually does not appear in shell history.",
        "- Keep bootstrap-only dependencies when they are still required for a fresh install.",
        "",
        "## Top Commands",
        "",
        "| Command | Count | Last Seen Rank | Score |",
        "| --- | ---: | ---: | ---: |",
    ]
    for command, command_use in top_commands:
        lines.append(
            f"| `{command}` | {command_use.count} | {command_use.last_seen_rank} | {command_use.score:.4f} |"
        )

    lines.extend(
        [
            "",
            "## Active Configured CLI Items",
            "",
            "| Name | Kind | Count | Score | Source |",
            "| --- | --- | ---: | ---: | --- |",
        ]
    )
    for item, command_use in item_rows(active, usage, limit):
        lines.append(
            f"| `{item.name}` | {item.kind} | {command_use.count} | {command_use.score:.4f} | `{source_link(item)}` |"
        )

    lines.extend(
        [
            "",
            "## Configured CLI Items Unseen In History",
            "",
            "These are candidates for removal, replacement, or archive. They are not",
            "automatic removals because some tools are bootstrap-only or invoked by other tools.",
            "",
            "| Name | Kind | Source |",
            "| --- | --- | --- |",
        ]
    )
    for item, _ in item_rows(unseen, usage, limit):
        lines.append(f"| `{item.name}` | {item.kind} | `{source_link(item)}` |")

    lines.extend(
        [
            "",
            "## Configured GUI Casks",
            "",
            "Shell history cannot reliably detect GUI app usage. Confirm these against",
            "current Applications, Dock/Login Items, Setapp/App Store usage, and personal preference.",
            "",
            "| Cask | Source |",
            "| --- | --- |",
        ]
    )
    for item in casks[:limit]:
        lines.append(f"| `{item.name}` | `{source_link(item)}` |")

    lines.extend(
        [
            "",
            "## Obsolete Syntax And Legacy References",
            "",
            "These should be handled before usage-based pruning because they are stale",
            "independent of whether a related tool is still useful.",
            "",
            "| Label | Source | Text |",
            "| --- | --- | --- |",
        ]
    )
    for path, line_number, label, text in obsolete[:limit]:
        safe_text = text.replace("|", "\\|")
        lines.append(f"| `{label}` | `{path}:{line_number}` | `{safe_text}` |")

    lines.extend(
        [
            "",
            "## Recommended Next Actions",
            "",
            "1. Mark every unseen CLI item as keep, remove, replace, archive, or manual.",
            "2. Convert kept formulae and casks into a curated `Brewfile`.",
            "3. Install and enable the configured history tooling before repeating this audit.",
            "4. Remove obsolete syntax in a separate commit from usage-based pruning.",
            "",
        ]
    )

    return "\n".join(lines)


def render_json(
    usage: dict[str, CommandUse],
    usage_source: str,
    raw_row_count: int,
    items: list[ConfiguredItem],
    obsolete: list[tuple[str, int, str, str]],
    limit: int,
) -> str:
    top_commands = sorted(
        usage.items(),
        key=lambda pair: (pair[1].count, pair[1].score, pair[1].last_seen_rank),
        reverse=True,
    )[:limit]

    payload = {
        "usage_source": usage_source,
        "raw_history_rows_scanned": raw_row_count,
        "top_commands": [
            {"name": name, "count": item.count, "last_seen_rank": item.last_seen_rank, "score": item.score}
            for name, item in top_commands
        ],
        "configured_items": [
            {
                "name": item.name,
                "kind": item.kind,
                "source": source_link(item),
                "count": usage_for_item(item, usage).count,
                "score": usage_for_item(item, usage).score,
            }
            for item in items[:limit]
        ],
        "obsolete": [
            {"source": f"{path}:{line}", "label": label, "text": text}
            for path, line, label, text in obsolete[:limit]
        ],
    }
    return json.dumps(payload, indent=2, sort_keys=True)


def main() -> int:
    args = parse_args()
    repo = args.repo.resolve()
    usage, usage_source, raw_row_count = aggregate_usage()
    items = configured_items(repo)
    obsolete = obsolete_patterns(repo)

    if args.format == "json":
        print(render_json(usage, usage_source, raw_row_count, items, obsolete, args.limit))
    else:
        print(render_markdown(repo, usage, usage_source, raw_row_count, items, obsolete, args.limit))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
