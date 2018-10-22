#!/usr/bin/env bash

function __dotsan__bash__init {
    case $1 in
        check)
            case $2 in
                required) echo "bash" ;;
                suggested) echo "alacritty" ;;
            esac
            ;;
        build)
            ;;
        install)
            __dotsan__link bash bashrc.sh .bashrc
            ;;
    esac
}
