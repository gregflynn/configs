#!/usr/bin/env bash


function __dotsan__alacritty__init {
    case $1 in
        check)
            case $2 in
                required) echo "alacritty" ;;
            esac
            ;;
        build)
            __dotsan__inject__colors alacritty alacritty.yml
            ;;
        install)
            __dotsan__link alacritty dist/alacritty.yml \
                    .config/alacritty/alacritty.yml
            ;;
    esac
}
