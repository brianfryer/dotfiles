# Copy all the dotfiles to the home directory
sh bootstrap.sh

# Install rvm
# https://rvm.io
curl -L https://get.rvm.io | bash -s stable --ruby

# Install nvm
# https://github.com/creationix/nvm
curl https://raw.github.com/creationix/nvm/master/install.sh | sh

# Install homebrew
# https://brew.sh
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# Install brews
sh ~/.brew
# Install casks
sh ~/.cask
# Set san defaults for OSX
sh ~/.osx

# Install resty
# https://github.com/micha/resty
curl -L http://github.com/micha/resty/raw/master/resty > resty

# Install Pygments for `cat` syntax highlighting
sudo easy_install Pygments

# Install z
# https://github.com/rupa/z
cd ~/dotfiles/z
git clone https://github.com/rupa/z.git
chmod +x ~/dotfiles/z/z.sh
