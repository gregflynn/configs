#!/usr/bin/env bash


function __dotsan__git__init {
    case $1 in
        check)
            case $2 in
                required) echo "git" ;;
            esac
            ;;
        install)
            __dotsan__link git gitconfig .gitconfig
            __dotsan__link git gitignore .gitignore
            ;;
    esac
}
