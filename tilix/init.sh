#!/usr/bin/env bash

function __dotsan__tilix__init {
    case $1 in
        check)
            case $2 in
                required) echo "tilix" ;;
                suggested) echo "bash" ;;
                noroot) echo 1 ;;
            esac
            ;;
        build)
            ;;
        install)
            dconf load /com/gexperts/Tilix/ < ${__dotsan__home}/tilix/tilix.dconf
            ;;
    esac
}
