# dotsanity
this is a mediocre at best attempt to keep my configuration files in a manageable place

![Image of dotsanity prompt](dotsanity.png)

## current features
* Pacman wrapper with AUR support
  * `pac [update|install|remove|search] [package_name]`
* bashrc
  * supports private variable sourcing
  * multi file organization
  * python fabric autocomplete
  * git autocomplete
* global git configuration
* vimrc

## install
```
git clone https://github.com/gregflynn/dotsanity.git ~/.sanity
bash ~/.sanity/setup.sh
```

## todo
features that are planned
* Visual Studio Code settings and package list
* Tilix settings

## goals
* never check in package code
  * just configure package managers
  * when managing with dropbox, this became a common merge conflict
* make it easy to apply configs
* No additional steps beyond `setup.sh`
