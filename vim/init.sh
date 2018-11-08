#!/usr/bin/env bash

function __dotsan__vim__init {
    case $1 in
        check)
            case $2 in
                required) echo "vim-runtime" ;;
                clionly) echo 1 ;;
            esac
            ;;
        build)
            if [ ! -e "$HOME/.vim" ]; then
                git clone https://github.com/VundleVim/Vundle.vim.git \
                        "$HOME/.vim/bundle/Vundle.vim"
            else
                pushd "$HOME/.vim/bundle/Vundle.vim" > /dev/null
                git pull
                popd > /dev/null
            fi
            ;;
        install)
            __dotsan__link vim vimrc.vim .vimrc
            vim +PluginInstall +qall
            ;;
    esac
}
