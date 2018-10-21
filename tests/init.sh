#!/usr/bin/env bash


function __dotsan__tests__init {
    case $1 in
        check)
            case $2 in
                required) echo "linux" ;;
                suggested) echo "bash" ;;
            esac
            ;;
        build)
            __dotsan__inject__colors tests index.html
            ;;
        install)
            ;;
    esac
}
