#!/usr/bin/env bash


function __dotsan__tests__init {
    case $1 in
        check)
            case $2 in
                required) echo "linux" ;;
            esac
            ;;
        build)
            __dotsan__inject tests index.html
            ;;
        install)
            ;;
    esac
}
