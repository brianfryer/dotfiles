# source ~/.profile
# [[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

eval $(/opt/homebrew/bin/brew shellenv)

# Load our dotfiles like ~/.bash_prompt, etc…
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
    echo "$file"
    [ -r "$file" ] && source "$file"
done
unset file

# to help sublimelinter etc with finding my PATHS
# case $- in
#    *i*) source ~/.extra
# esac

# generic colouriser
GRC=`which grc`
if [ "$TERM" != dumb ] && [ -n "$GRC" ]
    then
        alias colourify="$GRC -es --colour=auto"
        alias configure='colourify ./configure'
        for app in {diff,make,gcc,g++,ping,traceroute}; do
            alias "$app"='colourify '$app
    done
fi

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

# N
# export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

# Load RVM into a shell session *as a function*
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# rvm use 2.3.1

# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"

# Load pyenv
eval "$(pyenv init -)"

# z beats cd most of the time (github.com/rupa/z)
source ~/code/z/z.sh

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

# Activate the mise environment for zsh
eval "$(mise activate zsh)"

export PATH="/Users/brianfryer/.local/bin:$PATH"

export PATH="/Users/brianfryer/.bun/bin:$PATH"

#The binary must be in your PATH. On macOS/Linux, the default install location is ~/.local/bin/muninn — run echo $PATH to verify it includes ~/.local/bin. If not, add export PATH="$HOME/.local/bin:$PATH" to your ~/.zshrc or ~/.bashrc and restart your shell. On Windows, the default is %LOCALAPPDATA%\muninn — run $env:PATH in PowerShell to verify.

export 


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/brianfryer/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/brianfryer/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/brianfryer/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/brianfryer/google-cloud-sdk/completion.zsh.inc'; fi
