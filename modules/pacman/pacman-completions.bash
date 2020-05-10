#!/usr/bin/env bash

__pac__completion() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "pac" ]]; then
        opts="help info install list remove update web history search cache"
    fi

    case "${COMP_WORDS[1]}" in
        cache)
            opts="info prune revert show"
        ;;
        list)
            opts="explicit orphans"
        ;;
        remove|info|history)
            opts=$(pacman -Q | awk '{ print $1 }')
        ;;
        install|help|update|search|web)
            opts=""
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F __pac__completion pac
