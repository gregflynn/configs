#! /bin/bash


__pac__cache="/var/cache/pacman/pkg/"


function pac {
    local pkgs="${@:2}"

    case $1 in
        update)
            sudo pacman -Syy
            if [[ "$?" == "0" ]]; then
                sudo pacman -Syu
            fi
        ;;
        install)
            if [[ "${pkgs}" == "" ]]; then
                echo "Usage: pac install pkg1 [pkg2...]"
                return
            fi
            sudo pacman -S ${pkgs}
        ;;
        remove)
            if [[ "$pkgs" == "" ]]; then
                echo "Usage: pac remove pkg1 [pkg2...]"
                return
            fi

            for pkg in "$pkgs"; do
                if __pac__is__aur__pkg ${pkg}; then
                    __dotsan__warn "${pkg} is installed via the AUR"
                else
                    sudo pacman -Rs ${pkg}
                fi
            done
        ;;
        search)
            if [[ "${pkgs}" == "" ]]; then
                echo "Usage: pac search pkg"
                return 0
            fi

            echo "Official Repos:"
            echo "==============="
            local remote=`pacman -Ss ${pkgs}`
            if [[ "$remote" == "" ]]; then
                echo "Not Found"
            else
                echo "$remote"
            fi

            echo
            echo "Installed Packages:"
            echo "==================="
            local locals=`pacman -Qs ${pkgs}`
            if [[ "$locals" == "" ]]; then
                echo "Not Installed"
            else
                echo "$locals"
            fi
        ;;
        list)
            local OUTPUT=""
            local SEARCH="$3"

            case $2 in
                all)
                    echo "All Installed Packages"
                    OUTPUT=$(pacman -Q)
                ;;
                installed)
                    echo "Explicitly Installed Packages"
                    OUTPUT=$(pacman -Qen)
                ;;
                orphans)
                    echo "Orphaned Packages"
                    OUTPUT=$(pacman -Qtdq)
                ;;
                *)
                    # this case is now for `pac list search_term`
                    echo "All Installed Packages"
                    OUTPUT=$(pacman -Q)
                    SEARCH="$2"
                ;;
            esac

            if [[ "$SEARCH" != "" ]]; then
                # case where we had filtering and a search term
                echo "Filter: ${SEARCH}"
                OUTPUT=$(echo "${OUTPUT}" | grep -i ${SEARCH})
            fi

            echo
            echo "$OUTPUT"
        ;;
        cache)
            case $2 in
                prune)
                    if ! pacman -Q pacman-contrib >/dev/null 2>&1; then
                        __dotsan__error "pacman-contrib not installed, paccache unavailable"
                        return
                    fi

                    __pac__cache__info
                    echo

                    __dotsan__info "Removing uninstalled packages..."
                    paccache -r -c ${__pac__cache} -u
                    echo

                    __dotsan__info "Removing old packages..."
                    paccache -r -c ${__pac__cache} -k 10
                    echo

                    __pac__cache__info
                ;;
                show)
                    local pkg="$3"
                    if [[ "$pkg" == "" ]]; then
                        __dotsan__error "No package specified"
                        return
                    fi

                    __pac__cache__list ${pkg}
                ;;
                *)
                    if [[ "$2" != "" ]]; then
                        __dotsan__error "Unknown option: ${2}"
                        echo "Usage pac cache [prune|info|show]"
                        echo
                    fi
                ;&
                info)
                    __dotsan__echo "Pacman Package Cache" blue p p 1
                    __dotsan__echo " ${__pac__cache}" green
                    __pac__cache__info

                    local ignores=$(cat /etc/pacman.conf | grep -v ^# | grep IgnorePkg)
                    if [[ "${ignores}" != "" ]]; then
                        __dotsan__echo "${ignores}" red
                    fi
                ;;
            esac
        ;;
        web)
            xdg-open "https://www.archlinux.org/packages/"
        ;;
        *)
            echo "Usage: pac [update|install|remove|search|list|web|cache] [package_name]"
        ;;
    esac
}

function __pac__cache__info {
    local num_pkgs=$(ls -C ${__pac__cache} | wc -l)
    local cache_size=$(du -h -d 1 ${__pac__cache} | awk '{ print $1 }')
    __dotsan__echo "${num_pkgs}" green p p 1
    __dotsan__echo " Cached Packages" blue
    __dotsan__echo "${cache_size}" green p p 1
    __dotsan__echo " on disk" blue
}

function __pac__cache__list {
    local pkg="$1"

    # https://unix.stackexchange.com/a/45954/212439
    local esc=$(printf '\033')

    local current_ver=$(pacman -Q ${pkg} 2>/dev/null | awk '{ print $2 }')
    local current_file=$(ls -l ${__pac__cache} \
        | grep " ${pkg}-${current_ver}" \
        | awk '{ print $9 }')

    ls -ltr --time-style=+"%F %r" ${__pac__cache} \
        | grep -v ^t \
        | awk '{ print "\033[34m", $6, $7, $8, "\033[33m>\033[0m", $9}' \
        | grep " ${pkg}-"[0-9] \
        | sed "s/${current_file}/${esc}[32m${current_file} ${esc}[33minstalled${esc}[0m/g"
}
