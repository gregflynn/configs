#compdef aur
typeset -A opt_args
__aur__home='{AUR_HOME}'


__aur__cmp() {
    local state line

    _arguments -C \
        '1:command:->maincommand' \
        '*:subcommand:->subcommand'

    case "$state" in
        maincommand)
            local commands; commands=(
                'help:show help message' \
                'install:install packages from the AUR' \
                'remove:remove an AUR package' \
                'update:update all AUR installed packages' \
                'search:search the AUR for a package' \
                'web:search the web UI for AUR packages' \
                'clean:clean AUR build directories' \
                'inspect:cd into an AUR package source' \
                'list:show all AUR installed packages' \
            )
            _describe -t commands 'command' commands
        ;;
        subcommand)
            case "$line[1]" in
                clean|remove|update)
                    # one or more aur packages
                    _arguments -C "*: :($(ls $__aur__home))"
                ;;
                inspect|list)
                    # exactly one aur package
                    _arguments -C "2: :($(ls $__aur__home))"
                ;;
            esac
        ;;
    esac
}

__aur__cmp $@
