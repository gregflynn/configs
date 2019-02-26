#! /bin/bash

function badge {
    echo -n "#[fg=$2,bg=$3] $1 #[fg=$3,bg=default]"
}

function __git__status {
    local options="branch conflicted added changed untracked stash"

    gitstatus=$(git status -s -b --porcelain 2>/dev/null)

    if [[ "$?" -ne 0 ]]; then
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

    local output=$(badge '' 0 2)

    for option in ${options:-""}; do
        case "$option" in
            branch)
                IFS="^" read -ra branch_fields <<< "${branch/\#\# }"
                output="${output} #[fg=2]${branch_fields[0]}"
            ;;
            untracked)  if [[ "$untracked"  != "0" ]]; then output="${output} #[fg=1]?${untracked}";  fi ;;
            changed)    if [[ "$changes"    != "0" ]]; then output="${output} #[fg=1]~${changes}";    fi ;;
            conflicted) if [[ "$conflicted" != "0" ]]; then output="${output} #[fg=1]!${conflicted}"; fi ;;
            staged)     if [[ "$staged"     != "0" ]]; then output="${output} #[fg=2]+${staged}";     fi ;;
            stash)
                if [[ $(git stash list | wc -l) != "0" ]]; then
                    output="${output} #[fg=5]s"
                fi
            ;;
        esac
    done

    echo -n "${output} "
}

function __python__status {
    local b=$(badge '' 0 2)
    local venv_name=$(pyenv version-name)
    if [[ "$venv_name" != "system" ]]; then
        if [[ "$venv_name" == "" ]]; then
            echo -n "$b #[fg=1]N/A "
        else
            local prefix=$(pyenv prefix)
            local py_version=$($prefix/bin/python --version 2>&1 | cut -f 2 -d " ")
            echo -n "$b #[fg=2]$venv_name/$py_version "
        fi
    fi
}

function __docker__status {
    local num_containers=$(docker ps --quiet | wc -l)
    if [[ "$num_containers" != "0" ]]; then
        echo -n "$(badge '🐳' 0 4) $num_containers "
    fi
}

function main {
    local dir="$1"
    local badges="${@:2}"

    pushd ${dir} > /dev/null
    for badge in ${badges}; do
        case ${badge} in
            docker) __docker__status ;;
            git) __git__status ;;
            python) __python__status ;;
        esac
    done
    popd > /dev/null
}
main $@
