#!/usr/bin/env bash

function __dotsan__awesome__init {
    case $1 in
        check)
            case $2 in
                required) echo "awesome" ;;
                suggested) echo "gpmdp" ;;
            esac
            ;;
        build)
            __dotsan__inject awesome theme.lua
            ;;
        install)
            mkdir -p .config/awesome/util
            mkdir -p .config/awesome/widgets
            __dotsan__mirror__link awesome mirror .config/awesome
            __dotsan__link awesome dist/theme.lua .config/awesome/theme.lua
            ;;
    esac
}
