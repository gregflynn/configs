#!/usr/bin/env bash


__sys__completion() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "sys" ]]; then
        opts="help log last list status start stop restart enable disable"
    fi

    case "${COMP_WORDS[1]}" in
        log|status|start|stop|restart|enable|disable)
            opts=$(__sys__list)
        ;;
        help|last|list)
            opts=""
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}

complete -F __sys__completion sys
