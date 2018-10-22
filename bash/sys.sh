#! /bin/bash

#
# This file is here solely because for some reason I can't get used to the
# order of parameters to `systemctl`
#

function sys {
    case $1 in
        log)
            sudo journalctl -xe
        ;;
        lastlog) ;&
        lastboot)
            sudo journalctl --boot=-1
        ;;
        *)
            if [ "$#" == "2" ]; then
                case $2 in
                    log)
                        sudo journalctl -xu $1
                    ;;
                    start)
                        sudo systemctl $2 $1
                        sudo systemctl --no-pager status $1
                    ;;
                    *)
                        sudo systemctl $2 $1
                    ;;
                esac
            else
                echo "Usage: sys [log|lastlog|lastboot]"
                echo "       sys [service name] [log|start|stop|restart|enable|disable]"
            fi
        ;;
    esac
}
