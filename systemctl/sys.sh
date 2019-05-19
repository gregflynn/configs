#! /bin/bash


__sys__hl() {
    __dsc__ncho "$1" yellow
}


__sys__opt() {
    __dsc__ncho "$1" p p i
}


__sys__help() {
    local cmd=$(__sys__hl COMMAND)
    local opt_svc=$(__sys__opt "[service]")
    local nopt_svc=$(__sys__opt "service")

    echo "    Systemd service wrapper

    $(echo -en $'\uf061') sys $cmd $(__sys__opt "[service]")

    System $cmd options

        $(__sys__hl help)
            - show this help message

        $(__sys__hl last)
            - show the systemd log for the previous boot session

        $(__sys__hl list) $(__sys__opt "[filter]")
            - show all systemd units available

        $(__sys__hl log) $opt_svc
            - show the systemd log for the current boot session

    Service $cmd options

        $(__sys__hl status) $nopt_svc
            - print the current status of the given service

        $(__sys__hl start) $nopt_svc
            - start the given service and print the startup output

        $(__sys__hl stop) $nopt_svc
            - stop the given service

        $(__sys__hl restart) $nopt_svc
            - restart the given service

        $(__sys__hl enable) $nopt_svc
            - enable the given service for starting at boot

        $(__sys__hl disable) $nopt_svc
            - disable the given service from starting on boot
    "
}


__sys() {
    case $1 in
        help) __sys__help ;;
        log)  __sys__log  ;;
        last) sudo journalctl --boot=-1 ;;
        list) __sys__list $2 ;;
        start)
            sudo systemctl start $2
            sudo systemctl --no-pager status $2
        ;;
        status)
            sudo systemctl --no-pager status $2
        ;;
        stop|restart|enable|disable)
            sudo systemctl $1 $2
        ;;
        *) __sys__help ;;
    esac
}


__sys__log() {
    local unit="$1"

    if [[ "$unit" == "" ]]; then
        sudo journalctl -xe
    else
        sudo journalctl -xeu ${unit}
    fi
}


__sys__list() {
    local filter="$1"

    local units=$(systemctl list-unit-files --no-pager | grep -E 'enabled|disabled' | awk '{ print $1 }')

    if [[ "$filter" != "" ]]; then
        units=$(echo "$units" | grep "$filter")
    fi

    echo "$units"
}
