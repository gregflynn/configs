#! /usr/bin/env bash


function __dotsan__zsh__init {
    case $1 in
        check)
            case $2 in
                required)
                    echo "zsh oh-my-zsh-git"
                ;;
                clionly)
                    # echo any output here to indicate a module
                    # should still be installed in cli only contexts
                    echo "1"
                ;;
            esac
            ;;
        build)
            # prepare configuration files for linking
            ;;
        install)
            # link up configuration files
            __dotsan__link zsh zshrc .zshrc
            ;;
    esac
}

