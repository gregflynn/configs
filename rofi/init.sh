#!/usr/bin/env bash


function __dotsan__rofi__init {
    case $1 in
        check)
            case $2 in
                required) echo "rofi" ;;
                suggested) echo "rofi-calc" ;;
            esac
            ;;
        build)
            __dotsan__inject__colors rofi rofi-theme.rasi
            ;;
        install)
            mkdir -p "$HOME/.config/rofi"
            __dotsan__link rofi rofi.config .config/rofi/config
            __dotsan__link rofi dist/rofi-theme.rasi .config/rofi/dotsanity.rasi
            ;;
    esac
}
