#! /usr/bin/env bash


function __dotsan__MODULE__init {
    case $1 in
        check)
            case $2 in
                required)
                    # echo required packages
                    echo "linux"
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
            ;;
    esac
}

