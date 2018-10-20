#!/usr/bin/env bash


__tests__home="$__dotsan__home/tests"


function __dotsan__tests__init {
    case $1 in
        check)
            case $2 in
                required) echo "linux" ;;
                suggested) echo "bash" ;;
            esac
            ;;
        build)
            mkdir -p "$__tests__home/dist"
            # template our color viewer
            __dotsan__inject__colors "$__tests__home/index.html" "$__tests__home/dist/index.html"
            ;;
        install)
            ;;
    esac
}
