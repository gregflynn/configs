#!/usr/bin/env bash

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git checkout'
alias pull='git pull'
alias undo='git reset HEAD~'
alias gb="git branch --show-current | tr -d '[:space:]' | clip"

_concat_branch() {
    echo "$@" | sed 's/ /_/g'
}

gmb() {
    local b=$(_concat_branch $@)
    if ! [[ "$b" ]]; then
        echo "no branch name specified"
        return 1
    fi
    date="$(date '+%Y%m')"
    git checkout -b "${date}_gf_$b"
}

ydb() {
    if ! [[ "$1" ]]; then
        echo "no feature name given"
        return 1
    fi
    gmb "yo_dawg_i_heard_you_like_$@"
}

squash() {
    local base_branch="${1:-master}"
    local current_branch=$(git branch --show-current)
    local num_commits=$(git log ${base_branch}..${current_branch} | grep commit | wc -l)
    git rebase -i HEAD~$num_commits
}

if [[ "$ZSH_VERSION" == "" ]]; then
    if [[ -e /usr/share/git/completion/git-completion.bash ]]; then
        . /usr/share/git/completion/git-completion.bash
    fi
else 
    if [[ -e /usr/share/git/completion/git-completion.zsh ]]; then
        fpath=(/usr/share/git/completion/git-completion.zsh $fpath)
    fi
fi
