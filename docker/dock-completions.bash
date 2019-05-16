#!/usr/bin/env bash

__dock__completion() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "dock" ]]; then
        opts="help bash bg build down ps restart run up purge sys"
    fi

    case "${COMP_WORDS[1]}" in
        purge)
            opts="all containers images volumes"
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}

complete -F __dock__completion dock
