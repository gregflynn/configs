#!/usr/bin/env bash

export LS_COLORS='di=32;10:ln=34;10:so=33;10:pi=33;10:ex=31;10:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export PATH="$HOME/go/bin:$PATH"

export __dotsan__home="{DS_HOME}"
export HISTCONTROL=ignoreboth
export HISTSIZE=5000


alias df='df -h'
alias du='du -h'
alias ls='ls -h --color=auto'
alias ll='ls -l'
alias proc='ps ax | grep -i --color'
alias open='xdg-open'
alias dict='sdcv'
alias xmds="xmodmap $__dotsan__home/x11/xmodmap"

function bl {
    $@
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga
}

function fjnd {
    grep --color --include="*.js" -rli "$1" .
}

function fknd {
    grep --color --include="*.java" --exclude="R.java" -rli "$1" .
    grep --color --include="*.xml" -rli "$1" .
}

function __ds__complete {
    if command -v complete > /dev/null; then
        complete -F $1 $2
    fi
}
