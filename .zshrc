# Homebrew installs into /opt/homebrew on Apple Silicon. `brew shellenv` exports
# PATH, MANPATH, and INFOPATH for formulae installed by Brewfile. This is guarded
# because a fresh machine may source .zshrc before Homebrew exists.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Load shared shell fragments. `~/.extra` is intentionally first so private,
# machine-local PATH and credential-adjacent settings can override committed
# defaults without being stored in this repository.
for file in ~/.{extra,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# highlighting inside manpages and elsewhere
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

##
## gotta tune that bash_history…
##

# timestamps for later analysis. www.debian-administration.org/users/rossen/weblog/1
export HISTTIMEFORMAT='%F %T '

# keep history up to date, across sessions, in realtime
#  http://unix.stackexchange.com/a/48113
setopt HIST_IGNORE_DUPS                        # no duplicate entries
setopt HIST_IGNORE_ALL_DUPS                    # remove older duplicates
setopt HIST_SAVE_NO_DUPS                       # don't save duplicates
setopt SHARE_HISTORY                           # share history across sessions
setopt APPEND_HISTORY                          # append to history, don't overwrite it
HISTSIZE=100000                                # big big history (default is 500)
SAVEHIST=$HISTSIZE                            # big big history

# ^ the only downside with this is [up] on the readline will go over all history not just this bash session.

# Load pyenv only when installed. Python version management is useful, but
# shell startup should not fail on a fresh machine before Brewfile has run.
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# z keeps a frecency-ranked directory database and makes repeated project
# navigation faster than typing full paths. The integration is guarded because
# the checkout lives outside this repo.
[ -r "$HOME/code/z/z.sh" ] && source "$HOME/code/z/z.sh"

##
## Completion…
##

# Enable zsh completions
autoload -Uz compinit
compinit

# zsh completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi


##
## better `cd`'ing
##

# Case-insensitive globbing (used in pathname expansion)
setopt NO_CASE_GLOB

# Autocorrect typos in path names when using `cd`
setopt CORRECT

# Add depot_tools to PATH for Aseprite development
export PATH="$HOME/development/Aseprite/depot_tools:$PATH"

# Activate mise when present. mise owns project runtime selection for tools
# such as Node, Ruby, Python, and other language ecosystems.
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.bun/bin:$PATH"

# Structured shell history. Atuin records command history in SQLite with richer
# metadata than raw zsh history files. Sync/account setup is intentionally left
# to the user; this only enables local shell integration when `atuin` is present.
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# Google Cloud SDK hooks are optional and machine-local. Source them only when
# the SDK has been installed outside this repo.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/path.zsh.inc"
fi

if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
