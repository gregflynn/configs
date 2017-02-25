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
alias ls='ls -h --color'
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
  grep --color --include="*.java" -rli "$1" .
  grep --color --include="*.xml" -rli "$1" .
}


#
# Git
#
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
