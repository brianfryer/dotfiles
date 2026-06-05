# Bash support is intentionally small because interactive shells use Zsh by
# default. Keep this file limited to shared environment fragments and Bash-only
# readline/prompt behavior so a fallback Bash session behaves predictably.

for file in ~/.{extra,exports,aliases,functions}; do
  [ -r "$file" ] && source "$file"
done
unset file

if [ -r "$HOME/.bash_prompt" ]; then
  source "$HOME/.bash_prompt"
fi

# Store enough Bash history to make occasional fallback sessions searchable.
# Zsh and Atuin remain the primary interactive-history path.
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT='%F %T '

if command -v shopt >/dev/null 2>&1; then
  shopt -s histappend
  shopt -s nocaseglob
  shopt -s cdspell
fi

# Homebrew installs Git's Bash completion when Git is installed from Brewfile.
# Guard the source path so Bash startup still works before Brewfile has run.
if command -v brew >/dev/null 2>&1; then
  git_completion="$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
  [ -r "$git_completion" ] && source "$git_completion"
  unset git_completion
fi

if type __git_complete >/dev/null 2>&1; then
  __git_complete g __git_main
fi
