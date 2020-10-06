[ -n "$PS1" ] && source ~/.bash_profile
export PATH="$HOME/.yarn/bin:$PATH"
# export PATH="$PATH:`yarn global bin`"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
