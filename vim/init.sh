#!/usr/bin/env bash

__vim__plug="$__dotsan__home/vim/dist/vim-plug"

function __dotsan__vim__init {
    case $1 in
        check)
            case $2 in
                required) echo "vim-runtime" ;;
                clionly) echo 1 ;;
            esac
            ;;
        build)
            mkdir -p "$HOME/.vim/autoload/airline/themes"
            if [ ! -e "$__vim__plug" ]; then
                git clone https://github.com/junegunn/vim-plug.git "$__vim__plug"
            else
                pushd "$__vim__plug" > /dev/null
                git pull
                popd > /dev/null
            fi
            ;;
        install)
            __dotsan__link vim vimrc.vim .vimrc
            __dotsan__link vim monokaipro.vim .vim/autoload/airline/themes/monokaipro.vim
            __dotsan__link vim dist/vim-plug/plug.vim .vim/autoload/plug.vim
            vim +PlugInstall +qall
            ;;
    esac
}
