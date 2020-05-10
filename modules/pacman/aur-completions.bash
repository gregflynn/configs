#!/usr/bin/env bash
__aur__home="{AUR_HOME}"

__aur__completion() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "aur" ]]; then
        opts="clean inspect install list remove search update web help"
    fi

    case "${COMP_WORDS[1]}" in
        clean|inspect|list|remove|update)
            opts=$(ls $__aur__home)
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}

complete -F __aur__completion aur
