#!/usr/bin/env bash

export __dotsan__home="{DS_HOME}"
export LS_COLORS='di=32;10:ln=34;10:so=33;10:pi=33;10:ex=31;10:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export PATH="{DS_BIN}:$HOME/.bin:$HOME/go/bin:$PATH"


alias df='df -h'
alias du='du -h'
alias ls='ls -h --color=auto'
alias ll='ls -l'
alias proc='ps ax | grep -i --color'
alias open='xdg-open'
alias dict='sdcv'
alias xmds="xmodmap $__dotsan__home/modules/x11/xmodmap"
alias ds='dotsan'
alias clip='xsel -i --clipboard'

bl() {
    $@
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga
}

fjnd() {
    grep --color --include="*.js" -rli "$1" .
}

fknd() {
    grep --color --include="*.java" --exclude="R.java" -rli "$1" .
    grep --color --include="*.xml" -rli "$1" .
}

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"


if [[ -e "$HOME/.pyenv" ]]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    eval "$(pyenv init -)"
    if [[ -e "$HOME/.pyenv/plugins/pyenv-virtualenv" ]]; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi


rmpyc() {
    find . -name '*.pyc' -exec rm -rf {} \;
    find . -name __pycache__ -exec rm -rf {} \;
}

alias pygrep='grep --color --include="*.py"'

fynd() {
    grep --color --include="*.py" -rli "$1" .
}
