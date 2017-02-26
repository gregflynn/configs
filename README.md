# dotsanity
this is a mediocre at best attempt to keep my configuration files in a manageable place

![Image of dotsanity prompt](dotsanity.png)

## current features
* bashrc
  * supports private variable sourcing
  * multi file organization
* vimrc
* global git ignore

## install
```
git clone git@github.com:gregflynn/dotsanity.git ~/.sanity
cd ~/.sanity && ./setup.sh
```

## todo
features that are planned
* Atom settings and package list
* Visual Studio Code settings and package list
* Terminix settings
* Stretch: Maybe?
  * Budgie settings

## goals
* never check in package code
  * just configure package managers
  * when managing with dropbox, this became a common merge conflict
* make it easy to apply configs
* keep additional steps to an absolute minimum
  * additional steps beyond running `./setup.sh`
