#! /usr/bin/env bash


function __dotsan__netdmenu__init {
    case $1 in
        check)
            case $2 in
                required) echo "networkmanager-dmenu-git" ;;
            esac
            ;;
        build)
            ;;
        install)
            mkdir -p $HOME/.config/networkmanager-dmenu
            __dotsan__link netdmenu config.ini .config/networkmanager-dmenu/config.ini
            ;;
    esac
}

