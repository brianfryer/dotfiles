# Dotfiles Refresh Audit

This repo is old enough that cleanup should happen from evidence, not from a
single large rewrite. The refresh process has two goals:

1. Remove or archive configuration for tools that are no longer used.
2. Preserve enough context that future Brian, or a new developer, can understand
   why each surviving tool exists.

## Safety Model

The command-history audit is intentionally non-mutating. It reads local history
and repository files, then reports aggregated command names. It does not modify
shell startup files, install packages, delete files, or print raw command
arguments.

That privacy boundary matters because shell history can contain database URLs,
tokens, passwords, private paths, customer names, and one-off operational
commands. Raw history lines should not be copied into committed docs.

## Evidence Sources

Use these sources together:

- Current repo configuration: `brew.sh`, `cask.sh`, `.zshrc`, `.aliases`,
  `.functions`, `.exports`, and future `Brewfile`.
- Local command history: Atuin if available, otherwise `~/.zsh_history` and
  `~/.bash_history`.
- Manual review for GUI apps and macOS settings.

Shell history is strong evidence for CLI tools, aliases, functions, package
managers, and developer runtimes. It is weak evidence for GUI apps because apps
like Chrome, Slack, Spotify, and Dropbox are usually launched outside the
terminal.

## Decision Buckets

Use these labels while reviewing the generated report:

- `keep`: actively used, still needed for bootstrap, or clearly required by a
  workflow that history cannot see.
- `remove`: obsolete, broken, no longer installable, or no longer wanted.
- `replace`: the workflow remains useful, but the configured tool should change
  to a modern equivalent.
- `archive`: not part of a default setup, but worth preserving as historical
  reference.
- `manual`: history cannot decide; inspect the machine, app usage, or current
  preference.

## Running The Audit

From the repo root:

```bash
python3 scripts/audit-command-usage.py > docs/usage-audit.md
```

The generated report should be reviewed before committing. It contains command
names, counts, source locations, and obsolete syntax flags, but not command
arguments.

For machine-readable output:

```bash
python3 scripts/audit-command-usage.py --format json > /tmp/dotfiles-usage-audit.json
```

## Refresh Order

1. Generate and review `docs/usage-audit.md`.
2. Mark every configured CLI item as `keep`, `remove`, `replace`, `archive`, or
   `manual`.
3. Convert the kept Homebrew formulae and casks into a curated `Brewfile`.
4. Add Atuin for structured future shell-history tracking.
5. Clean `.zshrc`, `.aliases`, and `.functions` using the reviewed decisions.
6. Rewrite bootstrap scripts with idempotent steps and detailed comments.
7. Keep macOS defaults separate from bootstrap, with the legacy `.osx` script
   archived and reviewed user-level defaults in `macos-defaults.sh`.

## Comment Standard

Comments should explain intent, assumptions, and side effects. Avoid comments
that merely restate the command.

Good comments answer:

- Why does this setting exist?
- What breaks if it is removed?
- Is it machine-specific, optional, or bootstrap-critical?
- Is there a modern replacement or known migration path?
- Does it touch global macOS state, credentials, startup behavior, or shell
  performance?

For example:

```bash
# Homebrew installs into /opt/homebrew on Apple Silicon. `brew shellenv`
# exports PATH, MANPATH, and INFOPATH so the rest of shell startup can find
# Homebrew-managed tools without hardcoding the full prefix.
#
# This must be guarded because a fresh macOS machine may source .zshrc before
# Homebrew is installed.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
```
