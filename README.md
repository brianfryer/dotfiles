For installation on a fresh machine...
```
curl -u 'brianfryer' -L -o dotfiles.zip https://api.github.com/repos/brianfryer/dotfiles/tarball
# unzip the files then continue
./bootstrap.sh && cd ~
./install.sh
```
... then close and re-open terminal.