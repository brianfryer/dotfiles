# Dotfiles Usage Audit

This report compares command-like things configured by this repo against
local command-history usage. It intentionally reports command names only,
not raw command lines or arguments.

## Summary

- Repository: `/Users/brianfryer/development/dotfiles`
- Usage source: `shell_history`
- Raw history rows scanned: `9922`
- Configured command-like items found: `49`
- Active configured CLI items: `23`
- Configured CLI items unseen in history: `15`
- Configured GUI casks: `11`
- Obsolete syntax references found: `0`

## Privacy Rules

- Do not paste raw shell-history lines into this repo.
- Treat command-name counts as evidence, not proof.
- Formulae may match known command aliases, such as `imagemagick` -> `magick`.
- Review casks manually; GUI app usage usually does not appear in shell history.
- Keep bootstrap-only dependencies when they are still required for a fresh install.

## Top Commands

| Command | Count | Last Seen Rank | Score |
| --- | ---: | ---: | ---: |
| `pnpm` | 1479 | 9084 | 0.9704 |
| `cd` | 1125 | 9914 | 0.8441 |
| `bun` | 862 | 9402 | 0.7105 |
| `git` | 415 | 8942 | 0.4978 |
| `code` | 290 | 9434 | 0.4602 |
| `z` | 243 | 9430 | 0.4394 |
| `rm` | 216 | 9544 | 0.4316 |
| `mise` | 212 | 9410 | 0.4251 |
| `ls` | 200 | 9423 | 0.4203 |
| `bunx` | 172 | 9366 | 0.4060 |
| `defaults` | 140 | 9888 | 0.4103 |
| `supabase` | 124 | 3335 | 0.1721 |
| `..` | 119 | 9426 | 0.3848 |
| `cat` | 116 | 9922 | 0.4010 |
| `yarn` | 89 | 8593 | 0.3422 |
| `mkdir` | 78 | 8665 | 0.3399 |
| `railway` | 67 | 9428 | 0.3620 |
| `curl` | 51 | 9226 | 0.3479 |
| `grep` | 49 | 8174 | 0.3099 |
| `npm` | 48 | 8329 | 0.3149 |
| `g` | 45 | 8560 | 0.3217 |
| `which` | 42 | 9918 | 0.3683 |
| `brew` | 39 | 9908 | 0.3666 |
| `find` | 38 | 9725 | 0.3598 |
| `mv` | 34 | 9126 | 0.3369 |
| `docker` | 29 | 7350 | 0.2720 |
| `cp` | 28 | 8051 | 0.2963 |
| `open` | 27 | 9143 | 0.3344 |
| `psql` | 27 | 3995 | 0.1528 |
| `echo` | 23 | 9904 | 0.3595 |
| `pg_restore` | 22 | 229 | 0.0177 |
| `npx` | 21 | 8570 | 0.3115 |
| `...` | 20 | 9912 | 0.3584 |
| `touch` | 16 | 9546 | 0.3438 |
| `happy` | 16 | 9112 | 0.3285 |
| `stripe` | 15 | 9375 | 0.3373 |
| `sed` | 14 | 7775 | 0.2804 |
| `pg_dump` | 14 | 7341 | 0.2651 |
| `/usr/libexec/PlistBuddy` | 13 | 9660 | 0.3465 |
| `scripts/start-database.sh` | 13 | 8692 | 0.3123 |

## Active Configured CLI Items

| Name | Kind | Count | Score | Source |
| --- | --- | ---: | ---: | --- |
| `bun` | formula | 862 | 0.7105 | `Brewfile:14` |
| `bun` | shell_integration | 862 | 0.7105 | `.zshrc:91` |
| `git` | formula | 415 | 0.4978 | `Brewfile:8` |
| `z` | shell_integration | 243 | 0.4394 | `.zshrc:53` |
| `rm` | alias | 216 | 0.4316 | `.aliases:16` |
| `mise` | formula | 212 | 0.4251 | `Brewfile:13` |
| `mise` | shell_integration | 212 | 0.4251 | `.zshrc:86` |
| `..` | alias | 119 | 0.3848 | `.aliases:8` |
| `g` | alias | 45 | 0.3217 | `.aliases:23` |
| `brew` | shell_integration | 39 | 0.3666 | `.zshrc:5` |
| `mv` | alias | 34 | 0.3369 | `.aliases:15` |
| `cp` | alias | 28 | 0.2963 | `.aliases:17` |
| `...` | alias | 20 | 0.3584 | `.aliases:9` |
| `gbc` | alias | 7 | 0.2113 | `.aliases:24` |
| `zsh` | formula | 6 | 0.3526 | `Brewfile:9` |
| `ffmpeg` | formula | 6 | 0.3337 | `Brewfile:17` |
| `miseenv` | function | 5 | 0.3205 | `.functions:141` |
| `gcloud` | shell_integration | 4 | 0.3274 | `.zshrc:102` |
| `pyenv` | formula | 3 | 0.3157 | `Brewfile:10` |
| `pyenv` | shell_integration | 3 | 0.3157 | `.zshrc:47` |
| `tree` | formula | 2 | 0.0212 | `Brewfile:19` |
| `coreutils` | formula | 1 | 0.3502 | `Brewfile:7` |
| `imagemagick` | formula | 1 | 0.2617 | `Brewfile:18` |

## Configured CLI Items Unseen In History

These are candidates for removal, replacement, or archive. They are not
automatic removals because some tools are bootstrap-only or invoked by other tools.

| Name | Kind | Source |
| --- | --- | --- |
| `wifi-password` | formula | `Brewfile:20` |
| `ripgrep` | formula | `Brewfile:23` |
| `bat` | formula | `Brewfile:24` |
| `jq` | formula | `Brewfile:25` |
| `diff-so-fancy` | formula | `Brewfile:28` |
| `atuin` | formula | `Brewfile:32` |
| `c` | alias | `.aliases:20` |
| `ip` | alias | `.aliases:27` |
| `md` | function | `.functions:15` |
| `json` | function | `.functions:22` |
| `gr` | function | `.functions:44` |
| `server` | function | `.functions:60` |
| `gifify` | function | `.functions:81` |
| `localip` | function | `.functions:114` |
| `brew_update` | function | `.functions:165` |

## Configured GUI Casks

Shell history cannot reliably detect GUI app usage. Confirm these against
current Applications, Dock/Login Items, Setapp/App Store usage, and personal preference.

| Cask | Source |
| --- | --- |
| `divvy` | `Brewfile:35` |
| `dropbox` | `Brewfile:36` |
| `firefox` | `Brewfile:37` |
| `github` | `Brewfile:38` |
| `google-chrome` | `Brewfile:39` |
| `slack` | `Brewfile:40` |
| `sonos` | `Brewfile:41` |
| `spotify` | `Brewfile:42` |
| `steam` | `Brewfile:43` |
| `google-drive` | `Brewfile:46` |
| `sequel-ace` | `Brewfile:47` |

## Obsolete Syntax And Legacy References

These should be handled before usage-based pruning because they are stale
independent of whether a related tool is still useful.

| Label | Source | Text |
| --- | --- | --- |

## Recommended Next Actions

1. Mark every unseen CLI item as keep, remove, replace, archive, or manual.
2. Convert kept formulae and casks into a curated `Brewfile`.
3. Install and enable the configured history tooling before repeating this audit.
4. Remove obsolete syntax in a separate commit from usage-based pruning.

