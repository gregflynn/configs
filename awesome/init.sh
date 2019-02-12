#!/usr/bin/env bash

function __dotsan__awesome__init {
    case $1 in
        check)
            case $2 in
                required) echo "awesome gpmdp lain-git vicious redshift flameshot" ;;
            esac
            ;;
        build)
            __dotsan__inject awesome theme.lua
            ;;
        install)
            mkdir -p $HOME/.config/awesome/util
            mkdir -p $HOME/.config/awesome/widgets
            __dotsan__mirror__link awesome mirror .config/awesome
            __dotsan__link awesome dist/theme.lua .config/awesome/theme.lua

            flameshot config \
                --maincolor "#$__dotsan__hex__red" \
                --contrastcolor "#$__dotsan__hex__background" \
                --showhelp false \
                --trayicon false
            ;;
    esac
}
