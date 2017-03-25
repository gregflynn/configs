# dotsanity
this is a mediocre at best attempt to keep my configuration files in a manageable place

![Image of dotsanity prompt](dotsanity.png)

## current features
* Arch User Repository cli for install/remove/update/search
  * `aur [update|install|remove|search] [package_name]`
* Pacman wrappers
  * `pac [update|install|remove|search] [package_name]`
* Atom settings and packages (via `apmsync` command)
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
* Terminix settings
* Budgie settings
* convert xmodmap to xkb
  * hopefully this fixes randomly losing it during session?
  * can delete `xm` alias once this is figured out

## goals
* never check in package code
  * just configure package managers
  * when managing with dropbox, this became a common merge conflict
* make it easy to apply configs
* No additional steps beyond `setup.sh`
