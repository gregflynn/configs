#compdef pac
typeset -A opt_args

__pac__cmp() {
    local state line

    _arguments -C \
        '1:command:->maincommand' \
        '*:subcommand:->subcommand'

    case "$state" in
        maincommand)
            local commands; commands=(
                'help:show help message' \
                'info:show package information' \
                'install:install packages' \
                'list:list installed packages' \
                'remove:remove installed packages' \
                'update:update installed packages' \
                'web:open and serch the web ui' \
                'history:show install history of package' \
                'search:search for a package' \
                'cache:manage local pacman cache' \
            )
            _describe -t commands 'command' commands
        ;;
        subcommand)
            local subs
            case "$line[1]" in
                cache)
                    _describe -t subs 'subcommand' ('info:' 'prune:' 'revert:' 'show:')
                ;;
                list)
                    _describe -t subs 'subcommand' ('explicit:' 'orphans:')
                ;;
                remove)
                    # one or more packages
                    _arguments -C "*: :($(pacman -Q | awk '{ print $1 }'))"
                ;;
                info|history)
                    # one package
                    _arguments -C "2: :($(pacman -Q | awk '{ print $1 }'))"
                ;;
            esac
        ;;
    esac
}

__pac__cmp $@
