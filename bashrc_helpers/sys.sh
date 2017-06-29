#! /bin/bash

#
# This file is here solely because for some reason I can't get used to the
# order of parameters to `systemctl`
#

function sys() {
    case $1 in
        log)
            sudo journalctl -xe
        ;;
        *)
            if [ "$#" == "2" ]; then
                sudo systemctl $2 $1
            else
                echo "Usage: sys log"
                echo "       [service name] [start|stop|restart|enable|disable]"
            fi
        ;;
    esac
}
