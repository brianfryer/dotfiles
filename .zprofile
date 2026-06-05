# Login-shell setup.
#
# Keep this file narrow. Interactive aliases, functions, history, completions,
# and prompt behavior belong in `.zshrc`; `.zprofile` should prepare environment
# needed before the interactive shell starts.

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
