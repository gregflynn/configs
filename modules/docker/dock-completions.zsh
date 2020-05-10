#compdef dock
typeset -A opt_args

__dock__cmp() {
    local state line

    _arguments -C \
        '1:command:->maincommand' \
        '2:subcommand:->subcommand'

    case "$state" in
        (maincommand)
            local commands; commands=(
                'help:show help message' \
                'bash:execute a bash shell in a service container' \
                'bg:bring up services in the background' \
                'build:build services in the foreground' \
                'down:bring down services' \
                'edit:edit the current docker compose file' \
                'ps:list running containers' \
                'restart:restart services' \
                'run:run a one-time command on a container' \
                'up:bring up service containers' \
                'purge:purge docker cruft' \
                'sys:manage user-wide containers'
            )
            _describe -t commands 'command' commands
        ;;
        (subcommand)
            if [[ $line[1] == "purge" ]]; then
                local subs; subs=('all:' 'containers:' 'images:' 'volumes')
                _describe -t subs 'subcommand' subs
            fi
        ;;
    esac
}

__dock__cmp $@
