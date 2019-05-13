#!/usr/bin/env bash

__aur__home="$HOME/.aur"


function __pac__is__aur__pkg {
    if [[ -e "${__aur__home}/${1}" ]]; then
        return 0
    else
        return 1
    fi
}
