#! /bin/bash
AUR_HOME="$HOME/aur"

#
# "pac" is the entrance command for this file, see usage by typing "pac"
#
function pac() {
    if [[ "$2" == "-"* ]]; then
        local flag="$2"
        local pkgs="${@:3}"
        local pkg="$3"
    else
        local flag=""
        local pkgs="${@:2}"
        local pkg="$2"
    fi

    case $1 in
        # update from either pacman or AUR
        update)
            if [ "$flag" == "-aur" ]; then
                echo "Updating AUR caches..."
                # if packages aren't specified, update all
                if [ "$pkgs" == "" ]; then
                    pkgs=$(ls $AUR_HOME | xargs)
                fi
                aur_update_helper "$pkgs"
            else
                echo "Updating system packages..."
                sudo pacman -Syy
                if [ "$?" == "0" ]; then
                    sudo pacman -Syu
                fi
            fi
        ;;

        install)
            if [ "$pkg" == "" ]; then
                echo "Usage: pac install [-aur] pkg1 [pkg2...]"
                return
            fi

            if [ "$flag" == "-aur" ]; then
                echo "Installing $pkg from the AUR..."
                aur_install_helper $pkg
            else
                echo "Installing $pkgs..."
                sudo pacman -S $pkgs
            fi
        ;;

        remove)
            if [ "$pkg" == "" ]; then
                echo "Usage: pac remove pkg1 [pkg2...]"
                return
            fi

            echo "Removing $pkgs..."
            sudo pacman -Rs $pkgs
            if [ "$?" == "0" ]; then
                for pkg in "$pkgs"; do
                    if [ -e "$AUR_HOME/$pkg" ]; then
                        echo "Deleting $AUR_HOME/$pkg"
                        rm -rf "$AUR_HOME/$pkg"
                    fi
                done
            fi
        ;;

        search)
            if [ "$pkg" == "" ]; then
                echo "Usage: pac search [-l|-p] pkg1"
                return 0
            fi

            if [ "$flag" != "-l" ]; then
                echo "Official Repos:"
                echo "==============="
                remote=`pacman -Ss $pkg`
                if [ "$remote" == "" ]; then
                    echo "Not Found"
                else
                    echo "$remote"
                fi
            fi

            if [[ "$flag" != "-p" && "$flag" != "-l" ]]; then
                echo
                echo "Arch User Repository:"
                echo "====================="
                aur_search $pkg
            fi

            echo
            echo "Installed Packages:"
            echo "==================="
            locals=`pacman -Qs $pkg`
            if [ "$locals" == "" ]; then
                echo "Not Found"
            else
                echo "$locals"
            fi
        ;;

        list)
            local OUTPUT=""
            local SEARCH="$3"

            case $2 in
                aur)
                    echo "AUR Installed Packages"
                    OUTPUT=$(ll $AUR_HOME | awk '{ print $9}')
                ;;
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

        clean)
            aur_clean $2
        ;;

        *)
            echo "Usage: pac [update|install|remove|search|list] [package_name]"
        ;;
    esac
}

#
# Updates a list of packages on the AUR
# aur_update_helper "(list of packages)"
#
function aur_update_helper() {
    local needs_update=""

    for pkg in $1; do
        # make sure passed package has a checkout
        if [ ! -e $AUR_HOME/$pkg ]; then
            echo "$pkg not checked out, skipping"
            continue
        fi

        # update the git repo
        pushd $AUR_HOME/$pkg > /dev/null
        git pull -q > /dev/null
        popd > /dev/null

        aur_update_available $pkg
        aur_rc="$?"
        if [ "${aur_rc}" == "0" ]; then
            needs_update="$needs_update $pkg"
            print_version $pkg $(installed_version $pkg) $(aur_version $pkg)
        elif [ "${aur_rc}" == "1" ]; then
            print_version $pkg $(installed_version $pkg)
        elif [ "${aur_rc}" == "2" ]; then
            continue
        fi
    done

    if [ "$needs_update" == "" ]; then
        echo "No updates available"
        return 0
    fi

    echo
    echo
    echo "The following packages have updates available:"
    for pkg in $needs_update; do
        print_version $pkg $(installed_version $pkg) $(aur_version $pkg)
    done

    # prompt to continue
    echo
    read -p "Install updates? [y/n] " -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        built_pkgs=""

        for pkg in $needs_update; do
            aur_make ${pkg}
            built_pkgs="${built_pkgs} ${pkg}"
        done

        for pkg in ${built_pkgs}; do
            aur_install ${pkg}
        done
    fi
}

#
# Install a package from the AUR
#
function aur_install_helper() {
    mkdir -p "$AUR_HOME"

    # make sure that package doesn't exist already
    if [ -e $AUR_HOME/$1 ]; then
        pushd $AUR_HOME/$1 > /dev/null
        git pull -q > /dev/null
        popd > /dev/null
    else
        # clone the aur repo
        git clone aur:$1 $AUR_HOME/$1
    fi

    if [[ "$?" != "0" || "$(ls $AUR_HOME/$1)" == "" ]]; then
        if [ -e $AUR_HOME/$1 ]; then
            rm -rf $AUR_HOME/$1
        fi
        echo "AUR package not found: $1"
        return 1
    fi

    aur_make $1
    aur_install $1
}

#
# Build the given AUR package
#
function aur_make() {
    pushd $AUR_HOME/$1 > /dev/null

    # pkg specific hacks
    if [[ "$1" == "lain-git" && -e "src" && -e "src" ]]; then
        rm -rf lain/ src/
        git checkout -q master
    fi
    makepkg -s
    mk_rc="$?"

    popd > /dev/null
    return ${mk_rc}
}

#
# Build and install the given package
#
function aur_install() {
    pushd $AUR_HOME/$1 > /dev/null
    pkg_path=$(ls -la | grep "tar.xz" | tail -n 1 | awk '{print $9}')
    sudo pacman -U $pkg_path --needed --noconfirm
    popd > /dev/null
}

function aur_clean() {
    if [ ! -e "${AUR_HOME}/${1}" ]; then
        echo "$1 was not found in the AUR cache"
    else
        pushd ${AUR_HOME}/${1} > /dev/null
        git clean -f
        popd > /dev/null
    fi
}

#
# Search the AUR for $1
#
function aur_search() {
    curl -s "https://aur.archlinux.org/rpc.php?v=5&type=search&arg=$1" | \
        python "$HOME/.sanity/bashrc_helpers/aur_search.py"
}

#
# Check if $1 has an update remotely
# $? == 1 Up to date
# $? == 0 Update available
# $? == 2 Partial install
#
function aur_update_available() {
    local installed=$(installed_version $1)
    if [ "${installed}" == "" ]; then
        return 2
    fi

    local remote=$(aur_version $1)
    if [ "$installed" != "$remote" ]; then
        return 0
    else
        return 1
    fi
}

#
# Retrieve the locally installed version of $1
# stdout > version reported by pacman
#
function installed_version() {
    local pacman_version=$(pacman -Q $1 2>/dev/null)
    if [ "$?" == "0" ]; then
        echo $pacman_version | awk '{ print $2 }'
    fi
}

#
# Get the version number of an AUR package describe in PKGBUILD for $1
# stdout > AUR PKGBUILD version
#
function aur_version() {
    local pkgbuild="$AUR_HOME/$1/PKGBUILD"
    if [ ! -e $pkgbuild ]; then return 1; fi

    source "$pkgbuild"

    local base_version="$pkgver-$pkgrel"
    if [ "$epoch" != "" ]; then
        echo "$epoch:$base_version"
    else
        echo "$base_version"
    fi
}

#
# Print a colored version number printout to the terminal
# print_version (pkg name) (installed version) [remote version]
#
function print_version() {
    local C0=$'\e[0m'
    local C1=$'\e[34m'
    local C2=$'\e[31m'
    local C3=$'\e[32m'

    if [ "$3" == "" ]; then
        echo "Up to date: $C1$1$C0: $C3$2$C0"
    else
        echo "Upgrading $C1$1$C0: $C2$2$C0 => $C3$3$C0"
    fi
}
