# Dotfiles Usage Decisions

This is the human-review layer for `docs/usage-audit.md`. The audit report is
generated and should stay reproducible; this file is where we record judgement
calls before changing shell startup, bootstrap scripts, or package lists.

Status values:

- `keep`: Preserve in the refreshed default setup.
- `remove`: Delete from the refreshed default setup.
- `replace`: Preserve the workflow, but move to a newer tool or syntax.
- `archive`: Move out of the default path, but keep as historical reference.
- `manual`: Confirm with current machine/app usage before deciding.

These decisions are a first-pass draft. They intentionally bias toward
`manual` where shell history is weak evidence.

## CLI Formulae

| Item | Kind | Source | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- | --- | --- |
| `moreutils` | formula | `brew.sh:10` | remove | No direct usage signal and no shell config depends on it. | Drop from the default Brewfile unless a specific command from it is still wanted. |
| `findutils` | formula | `brew.sh:11` | remove | No `gfind`/`gxargs` usage signal; macOS defaults appear sufficient for current history. | Drop unless a future script explicitly requires GNU find semantics. |
| `gnu-sed` | formula | `brew.sh:12` | remove | No `gsed` usage signal, and the old install used deprecated `--default-names`. | Drop from default setup; use portable `sed` or explicit `gsed` only if needed. |
| `bash-completion` | formula | `brew.sh:18` | remove | Current shell surface is Zsh, not Bash. | Drop with the Bash-era cleanup. |
| `grc` | formula | `brew.sh:21` | remove | No usage signal for `grc` or `colourify`; aliases add startup complexity. | Remove formula and related colorizing aliases. |
| `wget` | formula | `brew.sh:24` | remove | No `wget` usage; `.aliases` maps `wget` to `curl -O` anyway. | Drop formula and probably remove the alias. |
| `vim` | formula | `brew.sh:27` | remove | No `vim`/`v` usage signal; macOS provides a fallback editor and `code` is heavily used. | Drop Homebrew Vim unless you want a terminal-editor fallback. |
| `entr` | formula | `brew.sh:30` | remove | No usage signal. | Drop from default setup. |
| `mtr` | formula | `brew.sh:33` | remove | No usage signal and setup mutates permissions with `sudo chmod 4755`. | Drop from default setup; reinstall manually when needed. |
| `the_silver_searcher` | formula | `brew.sh:41` | replace | No `ag` usage signal; `rg` is the modern default search tool. | Replace with `ripgrep` if not already installed elsewhere. |
| `fzf` | formula | `brew.sh:42` | remove | Direct history is weak for tools used through keybindings; current shell config does not show fzf setup. | Keep only if adding explicit shell integration. |
| `pv` | formula | `brew.sh:46` | remove | No usage signal. | Drop from default setup. |
| `rename` | formula | `brew.sh:47` | remove | No usage signal. | Drop from default setup. |
| `zopfli` | formula | `brew.sh:49` | remove | No usage signal and no current compression workflow references it. | Drop from default setup. |
| `terminal-notifier` | formula | `brew.sh:52` | remove | No usage signal and no scripts reference notifications. | Drop from default setup. |
| `pidcat` | formula | `brew.sh:54` | remove | Android/logcat workflow is not visible in current usage. | Drop from default setup. |
| `wifi-password` | formula | `brew.sh:60` | keep | Handy but sensitive utility; no usage signal. | Keep only if intentionally wanted. |
| `caskroom/cask/brew-cask` | formula | `cask.sh:5` | remove | Obsolete Homebrew cask bootstrap. | Delete during Brewfile conversion. |

## Aliases

| Item | Kind | Source | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- | --- | --- |
| `cd..` | alias | `.aliases:3` | remove | Typo alias has no usage signal. | Delete. |
| `....` | alias | `.aliases:5` | remove | Deeper `cd` shortcut has no usage signal; `..` and `...` are active. | Keep active shortcuts only. |
| `.....` | alias | `.aliases:6` | remove | Deeper `cd` shortcut has no usage signal. | Delete. |
| `cask` | alias | `.aliases:15` | remove | Points to deprecated `brew cask` syntax. | Delete. |
| `where` | alias | `.aliases:16` | remove | `which` is used directly; alias is not. | Delete. |
| `brwe` | alias | `.aliases:17` | remove | Typo alias has no usage signal. | Delete. |
| `subl` | alias | `.aliases:20` | remove | No usage signal and Sublime Text 3 setup is stale. | Delete with Sublime cleanup. |
| `ag` | alias | `.aliases:22` | replace | No `ag` usage; command depends on `the_silver_searcher`. | Replace with `rg` habits/config if needed. |
| `lsd` | alias | `.aliases:36` | remove | No usage signal. | Delete. |
| `c` | alias | `.aliases:42` | replace | Depends on `pygmentize` installed via obsolete `easy_install`. | Replace with `bat` or remove. |
| `clone` | function | `.aliases:47` | remove | Runs `bower install`, which is obsolete. | Delete or rewrite only if a shallow-clone helper is still desired. |
| `ga` | alias | `.aliases:55` | remove | No usage signal; broad `git add . -A` can be risky. | Delete. |
| `gcb` | alias | `.aliases:57` | remove | Duplicate of active `gbc`; no usage signal. | Keep `gbc` only if desired. |
| `gbl` | alias | `.aliases:58` | remove | No usage signal. | Delete. |
| `gc` | alias | `.aliases:59` | remove | No usage signal; commit message aliases are easy to misuse. | Delete. |
| `gp` | alias | `.aliases:60` | remove | No usage signal. | Delete. |
| `gs` | alias | `.aliases:61` | remove | No usage signal; `git` is used directly. | Delete unless you want to retrain on it. |
| `undopush` | alias | `.aliases:64` | remove | Force-push helper is risky and no usage signal. | Delete. |
| `gr` | alias | `.aliases:67` | replace | No usage signal; implementation uses backticks and fragile shell logic. | Replace with a safer `git root` function only if wanted. |
| `master` | alias | `.aliases:68` | remove | Branch naming has moved beyond `master`; no usage signal. | Delete. |
| `ip` | alias | `.aliases:71` | keep | Network helpers are often rare but useful. | Decide whether to keep a modern public-IP helper. |
| `wget` | alias | `.aliases:74` | remove | Hides `wget` behind `curl -O`; no usage signal. | Delete. |
| `cleanup_dsstore` | alias | `.aliases:77` | archive | Rare maintenance helper; safe but not part of everyday shell surface. | Move to an archived/manual maintenance script. |
| `diskspace_report` | alias | `.aliases:79` | remove | No usage signal. | Delete. |
| `free_diskspace_report` | alias | `.aliases:80` | remove | Alias of unused alias. | Delete. |
| `v` | alias | `.aliases:83` | remove | No `v`/`vim` usage signal. | Delete with Brew Vim removal. |
| `ungz` | alias | `.aliases:84` | remove | No usage signal. | Delete. |
| `fs` | alias | `.aliases:87` | remove | No usage signal. | Delete. |
| `emptytrash` | alias | `.aliases:90` | remove | Contains unrelated `/Users/paulirish/...` paths and destructive `rm -rf`. | Delete rather than modernize by default. |
| `brew_update` | alias | `.aliases:99` | replace | Uses obsolete `brew cask cleanup`, `brew prune`, and npm/gem global update assumptions. | Replace with documented `brew update && brew upgrade && brew cleanup` workflow if wanted. |
| `update_brew_npm_gem` | alias | `.aliases:100` | remove | Chains obsolete Ruby/npm global update assumptions. | Delete. |

## Functions

| Item | Kind | Source | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- | --- | --- |
| `md` | function | `.functions:4` | keep | Useful helper, but no usage signal. | Keep only if you still want `mkdir -p && cd`. |
| `cp_p` | function | `.functions:9` | remove | No usage signal. | Delete. |
| `la` | function | `.functions:14` | remove | No usage signal; custom `ls` parsing is fragile. | Delete or replace with a modern `eza`/`ls` setup. |
| `cdf` | function | `.functions:27` | remove | Finder integration is rare but potentially useful on macOS. | Keep only if still part of your workflow. |
| `json` | function | `.functions:32` | replace | Depends on `python`/`pygmentize`; no usage signal. | Replace with `jq` or remove. |
| `gitexport` | function | `.functions:43` | remove | Uses `git archive master`; no usage signal and branch default is stale. | Delete. |
| `gz` | function | `.functions:49` | remove | No usage signal. | Delete. |
| `escape` | function | `.functions:57` | remove | No usage signal. | Delete. |
| `unidecode` | function | `.functions:63` | remove | No usage signal. | Delete. |
| `extract` | function | `.functions:70` | remove | Archive extraction helpers can be useful but are rare. | Keep only if you prefer it over native tools. |
| `gifify` | function | `.functions:107` | replace | Duplicate function exists and no usage signal. | Delete duplicate; replace with documented ffmpeg recipe if needed. |
| `whiteboard` | function | `.functions:123` | remove | No usage signal and ImageMagick usage is minimal. | Delete. |
| `server` | function | `.functions:128` | replace | Depends on global `statik`; no usage signal. | Replace with `python3 -m http.server` or remove. |
| `localip` | function | `.functions:137` | keep | Network helper may be useful but is rare. | Keep only if modernized and documented. |
| `_localip` | function | `.functions:138` | remove | Internal helper should not be exported as a top-level decision. | Fold into `localip` or delete with it. |
| `whois` | function | `.functions:149` | remove | Overrides system `whois`; no usage signal. | Delete. |
| `camerausedby` | function | `.functions:163` | remove | Privacy/debug helper may be valuable despite rare use. | Keep only if tested on current macOS. |
| `gifify` | function | `.functions:171` | replace | Duplicate of earlier `gifify`; no usage signal. | Keep at most one modernized implementation. |
| `webmify` | function | `.functions:187` | remove | Old ffmpeg flags and no usage signal. | Delete. |
| `nullify` | function | `.functions:192` | remove | No usage signal; trivial to inline. | Delete. |
| `ssl-check` | function | `.functions:216` | remove | Project-specific Slate/mkcert helper; no usage signal. | Keep only if the Slate workflow still exists. |

## Shell Integrations And Generated Aliases

| Item | Kind | Source | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- | --- | --- |
| `colourify` | alias | `.zshrc:24` | remove | Generated by `grc`; no usage signal. | Remove with `grc`. |
| `configure` | alias | `.zshrc:25` | remove | Generated by `grc`; no usage signal. | Remove with `grc`. |
| `gdircolors` | shell_integration | `.exports:19` | remove | Supports LS_COLORS, but no direct usage signal. | Keep only if GNU colorized `ls` remains part of the setup. |

## GUI Casks

Shell history cannot prove whether GUI apps are used. These statuses are a
cleanup-oriented guess and should be checked against `/Applications`, Login
Items, Setapp/App Store installs, and current preference.

| Item | Kind | Source | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- | --- | --- |
| `adobe-creative-cloud` | cask | `cask.sh:9` | remove | Could still matter for design work, but shell history cannot tell. | Confirm installed/current subscription before keeping. |
| `bartender` | cask | `cask.sh:10` | remove | Menu bar utility usage is invisible to shell history. | Confirm current app preference. |
| `dashlane` | cask | `cask.sh:11` | remove | Password manager choice is personal and sensitive. | Keep only if it is still the active password manager. |
| `divvy` | cask | `cask.sh:12` | keep | Older window manager; likely replaced by Rectangle, Raycast, or native layouts. | Replace only if a current window-manager app is chosen. |
| `dropbox` | cask | `cask.sh:13` | keep | File sync usage is invisible to shell history. | Confirm current sync provider. |
| `filezilla` | cask | `cask.sh:14` | remove | Older FTP GUI with no current signal. | Drop from default setup. |
| `flux` | cask | `cask.sh:15` | remove | macOS Night Shift covers the common use case. | Drop unless you still prefer f.lux. |
| `firefox` | cask | `cask.sh:16` | keep | Browser usage is invisible to shell history. | Confirm whether it is still needed. |
| `github` | cask | `cask.sh:17` | keep | GitHub Desktop usage is invisible to shell history. | Keep only if still used. |
| `google-chrome` | cask | `cask.sh:18` | keep | Very likely a core browser even though shell history cannot prove it. | Convert to modern `cask "google-chrome"`. |
| `google-backup-and-sync` | cask | `cask.sh:19` | replace | Product was replaced by Google Drive for desktop. | Drop or replace with current `google-drive`. |
| `google-hangouts` | cask | `cask.sh:20` | remove | Product is obsolete. | Drop. |
| `google-nik-collection` | cask | `cask.sh:21` | remove | Old photo plugin suite; no current signal. | Drop unless intentionally used. |
| `homebrew-fonts` | cask | `cask.sh:22` | remove | Old tap/cask pattern, not a real app to install this way. | Replace with explicit `font-*` casks if needed. |
| `iterm2` | cask | `cask.sh:23` | remove | Terminal app preference is not visible in shell history. | Confirm current terminal. |
| `java` | cask | `cask.sh:24` | remove | Runtime need depends on current projects. | Keep only if a current project requires it. |
| `licecap` | cask | `cask.sh:25` | remove | Older screen capture tool. | Replace with current capture workflow if needed. |
| `sequel-pro` | cask | `cask.sh:26` | replace | Sequel Pro is stale; current alternatives include Sequel Ace/TablePlus. | Replace only if a DB GUI is wanted. |
| `skype` | cask | `cask.sh:27` | remove | No current signal and likely obsolete for the workflow. | Drop. |
| `slack` | cask | `cask.sh:28` | keep | Common work app, but GUI usage is invisible. | Confirm whether to keep. |
| `sonos` | cask | `cask.sh:29` | keep | Personal media app usage is invisible. | Confirm. |
| `spotify` | cask | `cask.sh:30` | keep | Personal media app usage is invisible. | Confirm. |
| `steam` | cask | `cask.sh:31` | keep | Personal/game app usage is invisible. | Confirm. |
| `sublime-text` | cask | `cask.sh:32` | remove | Repo references Sublime Text 3 and no `subl` usage appears. | Drop unless you still actively use Sublime. |
| `totalfinder` | cask | `cask.sh:33` | remove | System-modifying Finder utility; likely stale/risky on modern macOS. | Drop. |
| `vagrant` | cask | `cask.sh:34` | remove | No usage signal and modern workflows appear container/cloud oriented. | Drop unless a current VM workflow exists. |
| `virtualbox` | cask | `cask.sh:35` | remove | No usage signal; often problematic on modern macOS. | Drop unless Vagrant/VirtualBox workflow is confirmed. |

## Obsolete Syntax Cleanup

These should be handled before deeper usage-based pruning because the syntax or
tooling is stale independent of whether a related workflow still exists.

| Area | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- |
| `brew cask` usage | remove | `brew cask` syntax is obsolete. | Convert surviving apps to `cask "..."` entries in `Brewfile`. |
| old cask taps | remove | `caskroom/*` and old cask-driver taps are obsolete. | Delete during Brewfile conversion. |
| old Homebrew installer | replace | Ruby installer path is stale. | Use the current official Homebrew install command in bootstrap docs/scripts. |
| RVM installer | remove | Ruby version management may be unnecessary or handled by mise. | Prefer `mise` if Ruby is still needed. |
| `n` installer | remove | Node usage appears Bun/pnpm/mise-centered. | Use `mise` for Node if needed. |
| `easy_install Pygments` | remove | `easy_install` is obsolete and only supports the stale `c` alias. | Remove or replace `c` with `bat`. |
| Sublime Text 3 setup | remove | Current usage points to VS Code; Sublime setup references old paths. | Drop from default setup unless manually revived. |
| Bower in `clone` | remove | Bower is obsolete. | Delete the helper or rewrite without package-manager side effects. |

## Support Artifacts

These files are outside the main package, alias, and function inventory. They
still affect fresh clones because they are tracked or linked by setup scripts.

| Area | Draft Status | Rationale | Proposed Action |
| --- | --- | --- | --- |
| `.zshrc.backup` | remove | Backup copy of stale shell startup content. | Delete; Git history is the backup. |
| `bin/subl` | remove | Broken symlink to Sublime Text 3. | Delete with the Sublime cleanup. |
| `prefs/` | remove | App/project-specific preferences for Sublime, Illustrator, Lawnstarter hosts, and an ssh-add launch agent. | Delete from the default repo surface. |
| `.gitmodules` | remove | References `bin/git-friendly`, but the submodule checkout is absent. | Delete unless the submodule is intentionally restored. |
| `z` gitlink | remove | Gitlink has no `.gitmodules` mapping and breaks `git submodule status`. | Delete; source `z` from an external checkout when present. |
| `.dircolors` | remove | No shell startup path consumes GNU dircolors now. | Delete with the `gdircolors` cleanup. |
| Bash startup files | keep | Useful fallback shell support, but should not carry stale Zsh-era comments or old package-manager paths. | Keep minimal `.bash_profile`, `.bashrc`, and `.bash_prompt`. |
