#!/usr/bin/env bash

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git checkout'
alias pull='git pull'
alias undo='git reset HEAD~'
alias gb="git branch --show-current | tr -d '[:space:]' | clip"

#_concat_branch() {
#    echo "$@" | sed 's/ /_/g'
#}
#
#gmb() {
#    # turn all the args into the branch name
#    local b=$(_concat_branch $@)
#
#    # make sure something is specified
#    if ! [[ "$b" ]]; then
#        echo "no branch name specified"
#        return 1
#    fi
#
#    # check if there was a TP ticket at the beginning
#    if ! [[ $b == TP* ]]; then
#        local tp_number
#        echo -n "TP #: "
#        read tp_number
#
#        # don't require tp number
#        if [[ "$tp_number" != "" ]]; then
#            if [[ $tp_number =~ ^[Tt][Pp].* ]]; then
#                b="${tp_number}_${b}"
#            else
#                b="TP${tp_number}_${b}"
#            fi
#        fi
#    fi
#
#    # grab the YYYYMM portion
#    date="$(date '+%Y%m')"
#    git checkout -b "${date}_gf_$b"
#}
#
#ydb() {
#    if ! [[ "$1" ]]; then
#        echo "no feature name given"
#        return 1
#    fi
#    gmb "yo_dawg_i_heard_you_like_$@"
#}

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
