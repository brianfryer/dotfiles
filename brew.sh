#!/bin/bash

# Install command-line tools using Homebrew

brew update  # Make sure we’re using the latest Homebrew
brew upgrade # Upgrade any already-installed formulae

# GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install moreutils
brew install findutils # GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew reinstall gnu-sed --default-names # GNU `sed`, overwriting the built-in `sed`

# Bash 4
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
brew install bash
brew tap homebrew/versions
brew install bash-completion

# generic colouriser  http://kassiopeia.juls.savba.sk/~garabik/software/grc/
brew install grc

# Install wget with IRI support
brew install wget

# Install more recent versions of some OS X tools
brew install vim

# run this script when this file changes guy.
brew install entr

# mtr - ping & traceroute. best.
brew install mtr

    # allow mtr to run without sudo
    mtrlocation=$(brew info mtr | grep Cellar | sed -e 's/ (.*//') #  e.g. `/Users/paulirish/.homebrew/Cellar/mtr/0.86`
    sudo chmod 4755 $mtrlocation/sbin/mtr
    sudo chown root $mtrlocation/sbin/mtr

# Install other useful binaries
brew install the_silver_searcher
brew install fzf

brew install git
brew install imagemagick
brew install pv
brew install rename
brew install tree
brew install zopfli
brew install ffmpeg

brew install terminal-notifier

brew install pidcat   # colored logcat guy

brew install zsh

brew install pyenv

brew install wifi-password

# Remove outdated versions from the cellar
brew cleanup
