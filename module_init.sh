#! /usr/bin/env bash


function __dotsan__MODULE__init {
    case $1 in
        check)
            case $2 in
                required)
                    # echo required packages
                    echo "linux"
                ;;
                suggested)
                    # echo suggested packages
                    echo "bash"
                ;;
                noroot)
                    # echo any output here to indicate a module
                    # should not be installed if whoami == root
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

