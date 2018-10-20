#!/usr/bin/env bash


__alacritty__home="$__dotsan__home/alacritty"
__alacritty__dist="$__alacritty__home/dist"


function __dotsan__alacritty__init {
    case $1 in
        check)
            case $2 in
                required) echo "alacritty" ;;
                suggested) echo "" ;;
            esac
            ;;
        build)
            mkdir -p ${__alacritty__dist}
            __dotsan__inject__colors "$__alacritty__home/alacritty.yml" "$__alacritty__dist/alacritty.yml"
            ;;
        install)
            __dotsan__link alacritty dist/alacritty.yml .config/alacritty/alacritty.yml
            ;;
    esac
}
