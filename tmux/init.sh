#!/usr/bin/env bash


__tmux__plugins="$HOME/.tmux/plugins/tpm"


function __dotsan__tmux__init {
    case $1 in
        check)
            case $2 in
                required) echo "tmux" ;;
                clionly) echo 1 ;;
            esac
            ;;
        build)
            if [[ ! -e ${__tmux__plugins} ]]; then
                git clone https://github.com/tmux-plugins/tpm ${__tmux__plugins}
            else
                pushd ${__tmux__plugins} > /dev/null
                git pull
                popd > /dev/null
            fi

            __dotsan__inject tmux tmux.conf
            ;;
        install)
            __dotsan__link tmux dist/tmux.conf .tmux.conf
            bash ${__tmux__plugins}/bin/install_plugins
            bash ${__tmux__plugins}/bin/update_plugins all
            ;;
    esac
}
