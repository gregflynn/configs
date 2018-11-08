#!/usr/bin/env bash

function __dotsan__x11__init {
    case $1 in
        check)
            case $2 in
                required) echo "lightdm scrot imagemagick xautolock i3lock-color compton" ;;
                suggested) echo "" ;;
                noroot) echo 1 ;;
            esac
            ;;
        build)
            __dotsan__inject x11 i3lock.sh
            __dotsan__inject x11 xprofile.sh
            ;;
        install)
            __dotsan__link x11 dist/xprofile.sh .xprofile
            ;;
    esac
}
