#!/usr/bin/env bash

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git checkout'
alias pull='git pull'
alias undo='git reset HEAD~'

function gmb {
    if ! [[ "$1" ]]; then
        echo "no branch name specified"
        return 1
    fi
    date="$(date '+%Y%m')"
    git checkout -b "${date}_gf_$1"
}

function ydb {
    if ! [[ "$1" ]]; then
        echo "no feature name given"
        return 1
    fi
    gmb "yo_dawg_i_heard_you_like_$1"
}

if [[ "$ZSH_VERSION" == "" ]]; then
    if [[ -e /usr/share/git/completion/git-completion.bash ]]; then
        source /usr/share/git/completion/git-completion.bash
    fi
fi
