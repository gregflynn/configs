#! /bin/bash


function __aur__push {
    # set current working directory for the given AUR package
    # $1 name of the AUR package to enter context for

    pushd "${__aur__home}/$1" > /dev/null
}


function __aur__pop {
    # return to the previous working directory

    popd > /dev/null
}


function __aur__hl {
    __dsc__ncho "$1" yellow
}


function __aur__opt {
    __dsc__ncho "$1" p p i
}


function __aur__help {
    # echo help information
    local cmd=$(__aur__hl COMMAND)
    local opt_pkg=$(__aur__opt "package")
    local opt_pkgs=$(__aur__opt "package [package2, ...]")

    echo "    Arch Linux User Repository Wrapper

    $(echo -en $'\uf061') aur $cmd $(__aur__opt "[package [package2 ...]]")

    General $cmd options

        $(__aur__hl help)
            - show this help message

        $(__aur__hl install) $opt_pkgs
            - install one or more packages from the AUR

        $(__aur__hl remove) $opt_pkgs
            - remove one or more AUR installed packages

        $(__aur__hl update) $opt_pkgs
            - update one or more AUR installed packages

    Search $cmd options

        $(__aur__hl search) $opt_pkg
            - search the AUR for a package

        $(__aur__hl web) $(__aur__opt "[package]")
            - Open and search the AUR web interface

    Maintenance $cmd options

        $(__aur__hl clean) $opt_pkgs
            - clean one or more aur build directories

        $(__aur__hl inspect) $opt_pkg
            - cd into the checkout directory for the given AUR package

        $(__aur__hl list) $(__aur__opt "[filter]")
            - show all packages installed from the AUR
    "
}


function __aur__completion {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    if [[ "${COMP_WORDS[0]}" == "aur" ]]; then
        opts="clean inspect install list remove search update web help"
    fi

    case "${COMP_WORDS[1]}" in
        clean|inspect|list|remove|update)
            opts=$(__aur__list)
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F __aur__completion aur


function aur {
    if ! command -v pacman > /dev/null; then
        __dsc__error "pacman not installed"
        return 1
    fi

    if ! [[ -d "${__aur__home}" ]]; then
        mkdir -p "${__aur__home}"
    fi

    local pkgs="${@:2}"

    case $1 in
        clean)   __aur__clean   "$pkgs" ;;
        inspect) __aur__inspect "$pkgs" ;;
        install) __aur__install "$pkgs" ;;
        list)    __aur__list    "$pkgs" ;;
        remove)  __aur__remove  "$pkgs" ;;
        search)  __aur__search  "$pkgs" ;;
        update)  __aur__update  "$pkgs" ;;
        web)     __aur__web     "$pkgs" ;;
        *)       __aur__help ;;
    esac
}


function __aur__pm {
    sudo pacman --color auto $@
}


function __aur__install {
    # install the given package names from the AUR
    # $1 list of space separated package names to install

    local pkgs="$1"

    if [[ "$pkgs" == "" ]]; then
        echo "Usage: aur install pkg1 [pkg2...]"
        return
    fi

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__update "$pkg"
        else
            local aur_path="$__aur__home/$pkg"

            git clone aur:${pkg} ${aur_path}

            if [[ "$?" != "0" || "$(ls ${aur_path})" == "" ]]; then
                if __pac__is__aur__pkg ${pkg}; then
                    rm -rf ${aur_path}
                fi
                __dsc__warn "$pkg not found on the AUR"
                continue
            fi

            __aur__build__pkg "$1"
            if [[ "$?" == "0" ]]; then
                __aur__install__built__pkg "$1"
            else
                __dsc__warn "$pkg failed to build"
            fi
        fi
    done
}


function __aur__remove {
    # remove the given packages
    # $1 list of space separated package names to remove

    local pkgs="$1"

    if [[ "$pkgs" == "" ]]; then
        echo "Usage: aur remove pkg1 [pkg2...]"
        return
    fi

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__pm -Rs ${pkg}
            if [[ "$?" == "0" ]]; then
                rm -rf "$__aur__home/$pkg"
            fi
        else
            __dsc__warn "$pkg not an AUR package"
        fi
    done
}


function __aur__update {
    # Update one or more packages on from the AUR
    # $1 list of packages to update (optional)
    local pkgs="$1"
    local yes=""

    if [[ "$pkgs" == "" ]]; then
        pkgs=$(__aur__list)
    else
        yes="y"
    fi

    local needs_update=""

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__needs__update "$pkg"
            local ret_val="$?"

            if [[ "$ret_val" == "0" ]]; then
                needs_update="$needs_update $pkg"
            fi

            __aur__print__version "$pkg" "$ret_val"
        else
            __dsc__warn "${pkg} not installed via AUR"
        fi
    done

    if [[ "$needs_update" == "" ]]; then
        echo "No updates available"
        return 0
    fi

    if [[ "$yes" == "" ]]; then
        echo
        echo "The following packages have updates available:"
        for pkg in ${needs_update}; do
            __aur__print__version "$pkg"
        done

        echo
        read -p "==> install updates? [y/n]: " -r
    fi

    if [[ "$yes" != "" || $REPLY =~ ^[Yy]$ ]]; then
        built_pkgs=""

        for pkg in ${needs_update}; do
            __aur__build__pkg "$pkg"
            if [[ "$?" == "0" ]]; then
                built_pkgs="$built_pkgs $pkg"
            else
                __dsc__warn "$pkg failed to build"
            fi
        done

        if [[ "$built_pkgs" != "" ]]; then
            echo "Acquiring elevated privileges"
            sudo echo "Granted"
            if [[ "$?" != "0" ]]; then
                echo "Failed to elevate privileges, exiting"
                return 1
            fi
            for pkg in ${built_pkgs}; do
                __aur__install__built__pkg "$pkg"
            done
        fi
    fi
}


function __aur__needs__update {
    # Check if $1 has an update remotely
    # $1 package name
    # $? == 1 Up to date
    # $? == 0 Update available
    # $? == 2 Partial install
    local pkg="$1"

    __aur__push "${pkg}"
    git checkout master > /dev/null 2>&1
    git pull -q > /dev/null
    __aur__pop

    local installed=$(__aur__local__version "$pkg")
    if [[ "${installed}" == "" ]]; then
        return 2
    fi

    local remote=$(__aur__remote__version "$pkg")
    if [[ "$installed" != "$remote" ]]; then
        return 0
    else
        return 1
    fi
}


function __aur__print__version {
    # Print a colored version number to the terminal
    # $1 name of the package
    # $2 specify "1" to only show local version
    local pkg="$1"
    local installed_version=$(__aur__local__version "$pkg")

    if [[ "$2" == "1" ]]; then
        __dsc__line "[OK]" green " $pkg" blue ": " white \
                "$installed_version" green
    else
        local remote_version=$(__aur__remote__version "$pkg")

        __dsc__line "[UP]" yellow " $pkg" blue ": " white \
                "$installed_version" yellow " => " white "$remote_version" green
    fi
}


function __aur__local__version {
    # Retrieve the locally installed version of the given package name
    # $1 name of the package to query the version of
    local pacman_version=$(pacman -Q "$1" 2>/dev/null)

    if [[ "$?" == "0" ]]; then
        echo ${pacman_version} | awk '{ print $2 }'
    fi
}


function __aur__remote__version {
    # Get the version number of an AUR package described in PKGBUILD given package
    # $1 name of the package to get the version for
    local pkgbuild="${__aur__home}/$1/PKGBUILD"
    if [[ ! -e ${pkgbuild} ]]; then return 1; fi

    source "$pkgbuild"

    local base_version="$pkgver-$pkgrel"
    if [[ "$epoch" != "" ]]; then
        echo "$epoch:$base_version"
    else
        echo "$base_version"
    fi
}


function __aur__build__pkg {
    # Build the given AUR package
    # $1 the aur package name to build
    __aur__push "$1"
    makepkg -sf
    mk_rc="$?"
    __aur__pop
    return ${mk_rc}
}


function __aur__install__built__pkg {
    # Install the given built package
    # $1 path to the built package file
    local pkg="$1"

    __aur__push "$pkg"
    remote_version=$(__aur__remote__version "$pkg")
    pkg_path=$(ls -la | grep "$remote_version" | head -n 1 | awk '{print $9}')
    __aur__pm -U ${pkg_path} --needed --noconfirm
    __aur__pop
}


function __aur__search {
    # search the AUR for a package
    # $1 package name to search for
    local pkgs="$1"

    if [[ "$pkgs" == "" ]]; then
        echo "Usage: aur search pkg1"
        return 0
    fi

    curl -s "https://aur.archlinux.org/rpc.php?v=5&type=search&arg=$pkgs" | \
        python "$__dotsan__home/bash/pac/aur_search.py"
}


function __aur__clean {
    # clean the aur build directory for the given packages
    # $1 package names to clean
    local pkgs="$1"

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__push "$pkg"
            git checkout master
            git clean -fdx
            __aur__pop
        else
            __dsc__warn "$pkg was not found in the AUR cache"
        fi
    done
}


function __aur__list {
    # list out package installed via the aur
    # $1 package name to filter by
    local list=$(ll "$__aur__home" | awk '{ print $9}')

    if [[ "$1" != "" ]]; then
        echo -e "$list" | grep "$1"
    else
        echo -e "$list"
    fi
}


function __aur__web {
    # Open the AUR website
    # $1 if supplied, search the AUR website for the given package
    local url="https://aur.archlinux.org/packages/"

    if [[ "$1" == "" ]]; then
        xdg-open "$url"
    else
        xdg-open "$url?K=$1"
    fi
}


function __aur__inspect {
    # Change working directory into AUR package's build directory
    # $1 package name
    local pkg="$1"

    if __pac__is__aur__pkg ${pkgs}; then
        __aur__push "$pkg"
    else
        __dsc__warn "$pkg is not installed from the AUR"
    fi
}
