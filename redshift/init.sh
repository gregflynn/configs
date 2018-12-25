#! /usr/bin/env bash


function __dotsan__redshift__init {
    case $1 in
        check)
            case $2 in
                required)
                    echo "redshift"
                ;;
            esac
            ;;
        build)
            # prepare configuration files for linking
            ;;
        install)
            mkdir -p $HOME/.config/redshift
            __dotsan__link redshift redshift.conf .config/redshift/redshift.conf
            ;;
    esac
}

