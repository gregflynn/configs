#! /bin/bash

function __git__status {
    local dir="$1"
    local options="${@:2}"

    gitstatus=$(cd $dir && git status -s -b --porcelain 2>/dev/null)

    if [[ "$?" -ne 0 ]]; then
        if [[ $options == *branch* ]]; then
            echo -n "none"
        fi
        return 0
    fi

    branch=""
    untracked=0
    conflicted=0
    changes=0
    staged=0

    # shamelessly stolen from https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh#L27-L49
    while IFS='' read -r line || [[ -n "$line" ]]; do
        status=${line:0:2}
        while [[ -n $status ]]; do
            case "$status" in
                #two fixed character matches, loop finished
                \#\#) branch="${line/\.\.\./^}"; break ;;
                \?\?) ((untracked++)); break ;;
                U?) ((conflicted++)); break;;
                ?U) ((conflicted++)); break;;
                DD) ((conflicted++)); break;;
                AA) ((conflicted++)); break;;
                #two character matches, first loop
                ?M) ((changes++)) ;;
                ?D) ((changes++)) ;;
                ?\ ) ;;
                #single character matches, second loop
                U) ((conflicted++)) ;;
                \ ) ;;
                *) ((staged++)) ;;
            esac
            status=${status:0:(${#status}-1)}
        done
    done <<< "$gitstatus"

    local output=""

    for option in ${options:-""}; do
        case "$option" in
            branch)
                IFS="^" read -ra branch_fields <<< "${branch/\#\# }"
                output="${output} ${branch_fields[0]}"
            ;;
            untracked)  if [[ "$untracked"  != "0" ]]; then output="${output} ?${untracked}";  fi ;;
            changed)    if [[ "$changes"    != "0" ]]; then output="${output} ~${changes}";    fi ;;
            conflicted) if [[ "$conflicted" != "0" ]]; then output="${output} !${conflicted}"; fi ;;
            staged)     if [[ "$staged"     != "0" ]]; then output="${output} +${staged}";     fi ;;
            stash)
                if git stash list 2>/dev/null; then
                    output="${output} s"
                fi
            ;;
        esac
    done

    echo -n ${output}
}

__git__status $@
