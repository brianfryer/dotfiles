# Bash reads .bashrc for non-login interactive shells. Delegate to
# .bash_profile so Bash sessions share one source of truth.
[ -n "$PS1" ] && [ -r "$HOME/.bash_profile" ] && source "$HOME/.bash_profile"
