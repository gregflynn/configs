#!/usr/bin/env bash

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"


if [[ -e "$HOME/.pyenv" ]]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    eval "$(pyenv init -)"
    if [[ -e "$HOME/.pyenv/plugins/pyenv-virtualenv" ]]; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi


function rmpyc {
    find . -name '*.pyc' -exec rm -rf {} \;
    find . -name __pycache__ -exec rm -rf {} \;
}

alias pygrep='grep --color --include="*.py"'

function fynd {
    grep --color --include="*.py" -rli "$1" .
}
