#!/usr/bin/env bash


__tmux__plugins="$HOME/.tmux/plugins/tpm"


function __dotsan__tmux__init {
    case $1 in
        check)
            case $2 in
                required) echo "tmux" ;;
                suggested) echo "" ;;
            esac
            ;;
        build)
            if [ ! -e ${__tmux__plugins} ]; then
                git clone https://github.com/tmux-plugins/tpm \
                        ${__tmux__plugins}
            else
                pushd ${__tmux__plugins} > /dev/null
                git pull
                popd > /dev/null
            fi
            ;;
        install)
            __dotsan__link tmux tmux.conf .tmux.conf
            ;;
    esac
}
