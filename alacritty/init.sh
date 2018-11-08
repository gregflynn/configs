#!/usr/bin/env bash


function __dotsan__alacritty__init {
    case $1 in
        check)
            case $2 in
                required) echo "alacritty" ;;
                noroot) echo 1 ;;
            esac
            ;;
        build)
            __dotsan__inject alacritty alacritty.yml
            ;;
        install)
            mkdir -p ${HOME}/.config/alacritty
            __dotsan__link alacritty dist/alacritty.yml \
                    .config/alacritty/alacritty.yml
            ;;
    esac
}
