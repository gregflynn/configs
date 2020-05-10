#compdef sys
typeset -A opt_args

__aur__cmp() {
    local state line

    _arguments -C \
        '1:command:->maincommand' \
        '*:subcommand:->subcommand'

    case "$state" in
        maincommand)
            local commands; commands=(
                'help:show help message' \
                'last:show the previous boot systemd log' \
                'list:show all systemd units' \
                'log:show the systemd log' \
                'status:show current unit status' \
                'start:start a systemd unit' \
                'stop:stop a systemd unit' \
                'restart:restart a systemd unit' \
                'enable:mark a unit for start on boot' \
                'disable:remove start at boot from service' \
            )
            _describe -t commands 'command' commands
        ;;
        subcommand)
            case "$line[1]" in
                log|list|status|start|stop|restart|enable|disable)
                    # exactly one systemd unit
                    _arguments -C "2: :($(sys list))"
                ;;
            esac
        ;;
    esac
}

__aur__cmp $@
