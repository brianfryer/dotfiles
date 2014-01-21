# rvm
# https://rvm.io
curl -L https://get.rvm.io | bash -s stable --ruby

# nvm
# https://github.com/creationix/nvm
curl https://raw.github.com/creationix/nvm/master/install.sh | sh

# homebrew
# https://brew.sh
ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)

# z
# https://github.com/rupa/z
cd ~/dotfiles/z
git clone https://github.com/rupa/z.git
chmod +x ~/dotfiles/z/z.sh

# for the c alias (syntax highlighted cat)
sudo easy_install Pygments
