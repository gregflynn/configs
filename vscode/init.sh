#!/usr/bin/env bash

function __dotsan__vscode__init {
    case $1 in
        check)
            case $2 in
                required) echo "visual-studio-code-bin" ;;
                suggested) echo "" ;;
            esac
            ;;
        build)
            # prepare configuration files for linking
            ;;
        install)
            mkdir -p "$HOME/.config/Code/User/snippets"
            __dotsan__mirror__link vscode User .config/Code/User
            # pushd vscode > /dev/null && python sync.py && popd > /dev/null
            ;;
    esac
}
