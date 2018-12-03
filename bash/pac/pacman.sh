#! /bin/bash


__pac__cache="/var/cache/pacman/pkg/"


function pac {
    local pkgs="${@:2}"

    case $1 in
        update)
            sudo pacman -Syy
            if [ "$?" == "0" ]; then
                sudo pacman -Syu
            fi
        ;;
        install)
            if [ "${pkgs}" == "" ]; then
                echo "Usage: pac install pkg1 [pkg2...]"
                return
            fi
            sudo pacman -S ${pkgs}
        ;;
        remove)
            if [ "$pkgs" == "" ]; then
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
            if [ "${pkgs}" == "" ]; then
                echo "Usage: pac search pkg"
                return 0
            fi

            echo "Official Repos:"
            echo "==============="
            local remote=`pacman -Ss ${pkgs}`
            if [ "$remote" == "" ]; then
                echo "Not Found"
            else
                echo "$remote"
            fi

            echo
            echo "Installed Packages:"
            echo "==================="
            local locals=`pacman -Qs ${pkgs}`
            if [ "$locals" == "" ]; then
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

            if [ "$SEARCH" != "" ]; then
                # case where we had filtering and a search term
                echo "Filter: ${SEARCH}"
                OUTPUT=$(echo "${OUTPUT}" | grep -i ${SEARCH})
            fi

            echo
            echo "$OUTPUT"
        ;;
        cache)
            if ! pacman -Q pacman-contrib >/dev/null 2>&1; then
                __dotsan__error "pacman-contrib not installed, paccache unavailable"
                return
            fi

            case $2 in
                show)
                    local pkg="$3"
                    if [ "$pkg" == "" ]; then
                        __dotsan__error "No package specified"
                        return
                    fi

                    ls -ltr --time-style=+"%F %r" ${__pac__cache} \
                        | grep -v ^t \
                        | awk '{ print "\033[34m", $6, $7, $8, "\033[33m>\033[0m", $9}' \
                        | grep " ${pkg}-"[0-9]
                ;;
                info) ;&
                *)
                    local num_pkgs=$(ls -C ${__pac__cache} | wc -l)
                    local cache_size=$(du -h -d 1 ${__pac__cache} | awk '{ print $1 }')

                    echo "Pacman Package Cache ${__pac__cache}"
                    echo -e "\t ${num_pkgs} Cached Packages"
                    echo -e "\t ${cache_size} on disk"
                ;;
            esac
        ;;
        web)
            xdg-open "https://www.archlinux.org/packages/"
        ;;
        *)
            echo "Usage: pac [update|install|remove|search|list|web] [package_name]"
        ;;
    esac
}
