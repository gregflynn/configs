# dotsanity
this is a mediocre at best attempt to keep my configuration files in a manageable place

## WARNING: Transitional, nothing works yet

## current files
* bashrc => ~/.bashrc
* vimrc => ~/.vimrc
* gitconfig => ~/.gitconfig
* setup.sh
  * this script sanely writes the symlinks to the git repo
  * this script finds itself and symlinks absolutely

## Install
```
git clone git@github.com:gregflynn/dotsanity.git ~/.sanity
cd ~/.sanity && ./setup.sh
```

## goals
* never check in package code
  * just configure package managers
  * when managing with dropbox, this became a common merge conflict
* make it easy to apply configs
* keep additional steps to an absolute minimum
  * additional steps beyond running `./setup.sh`
