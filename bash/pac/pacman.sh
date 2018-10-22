#! /bin/bash


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
        *)
            echo "Usage: pac [update|install|remove|search|list] [package_name]"
        ;;
    esac
}
