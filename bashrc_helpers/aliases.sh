#! /bin/bash

#
# Aliases and Variables
#
export LS_COLORS='di=33;10:ln=35;10:so=32;10:pi=33;10:ex=31;10:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="/home/greg/bin:$PYENV_ROOT/bin:$PATH"
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias df='df -h'
alias du='du -h'
alias ls='ls -h --color=auto'
alias ll='ls -l'
alias proc='ps ax | grep'
alias xm='xmodmap ~/.Xmodmap'
function bl() {
  $@
  paplay /usr/share/sounds/gnome/default/alerts/drip.ogg
}
function rmpyc() {
  find . -name '*.pyc' -exec rm -rf {} \;
  find . -name __pycache__ -exec rm -rf {} \;
}
function title() {
  echo -en "\033]0;$1\a"
}
alias reload='source ~/.bashrc'

#
# Grep
#
alias pygrep='grep --color --include="*.py"'
function fynd() {
  grep --color --include="*.py" -rli "$1" .
}
function fjnd() {
  grep --color --include="*.js" -rli "$1" .
}
function fknd() {
  grep --color --include="*.java" --exclude="R.java" -rli "$1" .
  grep --color --include="*.xml" -rli "$1" .
}

#
# Git
#
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'

#
# Pacman
#
alias pac='sudo pacman'
alias pacs='pacman -Ss'

AUR_HOME="$HOME/aur"
function aur() {
  case $1 in
    "")
      echo "Usage: aur [update|install] [package_name]"
    ;;
    "update")
      aur_update $2
    ;;
    "install")
      aur_install $2
    ;;
  esac
}
function aur_update() {
  for pkg in `ls $AUR_HOME | xargs`; do
    cd $AUR_HOME/$pkg && git pull
    cd $AUR_HOME/$pkg && makepkg -si
  done
}
function aur_install() {
  pkg_name="$1"
  clone_dir="$AUR_HOME/$pkg_name"

  # make sure that package doesn't exist
  if [ -e $clone_dir ]; then
    echo "Package already checked out: $pkg_name"
    echo "Did you mean?: aur update"
    return 1
  fi

  # clone the aur repo
  cd $AUR_HOME && git clone aur:$pkg_name $clone_dir
  if [ "$?" != "0" ]; then
    echo "AUR package not found: $pkg_name"
    return 1
  fi

  # run makepkg
  cd $AUR_HOME/$1 && makepkg -si
}
