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


function __aur__help {
    # echo help information

    echo "dotsanity AUR wrapper

    Usage: aur COMMAND package [package]

    COMMAND options
        install
            - install one or more packages from the AUR
    "
#    echo "Usage: aur [update|install|remove|search|list|clean] package names"
}


function aur {
    if ! command -v pacman > /dev/null; then
        __dotsan__error "pacman not installed"
        return 1
    fi

    if ! [[ -d "${__aur__home}" ]]; then
        mkdir -p "${__aur__home}"
    fi

    local pkgs="${@:2}"

    case $1 in
        install) __aur__install "${pkgs}" ;;
        list)
            ll ${__aur__home} | awk '{ print $9}'
        ;;
        remove)
            if [[ "${pkgs}" == "" ]]; then
                echo "Usage: aur remove pkg1 [pkg2...]"
                return
            fi

            for pkg in ${pkgs}; do
                if __pac__is__aur__pkg ${pkg}; then
                    sudo pacman -Rs ${pkg}
                    if [[ "$?" == "0" ]]; then
                        rm -rf "${__aur__home}/${pkg}"
                    fi
                else
                    __dotsan__warn "${pkg} not an AUR package"
                fi
            done
        ;;
        search)
            if [[ "${pkgs}" == "" ]]; then
                echo "Usage: aur search pkg1"
                return 0
            fi
            _aur_search "${pkgs}"
        ;;
        update)
            local selected_pkgs="1"
            if [[ "${pkgs}" == "" ]]; then
                pkgs=$(ls ${__aur__home} | xargs)
                selected_pkgs=""
            fi
            _aur_update "${pkgs}" "${selected_pkgs}"
        ;;
        clean)
            _aur_clean ${pkgs}
        ;;
        inspect)
            if __pac__is__aur__pkg ${pkgs}; then
                __aur__push "${pkgs}"
            else
                __dotsan__warn "${pkgs} is not installed from the AUR"
            fi
        ;;
        web)
            xdg-open "https://aur.archlinux.org/"
        ;;
        *) __aur__help ;;
    esac
}


function __aur__install {
    # install the given package names from the AUR
    # $1 list of space separated package names to install

    local pkgs="$1"

    if [[ "${pkgs}" == "" ]]; then
        echo "Usage: aur install pkg1 [pkg2...]"
        return
    fi

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            _aur_update ${pkg}
        else
            local aur_path="${__aur__home}/${pkg}"

            git clone aur:${pkg} ${aur_path}

            if [[ "$?" != "0" || "$(ls ${aur_path})" == "" ]]; then
                if __pac__is__aur__pkg ${pkg}; then
                    rm -rf ${aur_path}
                fi
                __dotsan__warn "${pkg} not found on the AUR"
                continue
            fi

            _aur_build $1
            if [[ "$?" == "0" ]]; then
                _aur_install_pkg $1
            else
                __dotsan__warn "${pkg} failed to build"
            fi
        fi
    done
}

#
# Updates a list of packages from the AUR
#
function _aur_update {
    local pkgs="$1"
    local yes="$2"
    local needs_update=""

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__push "${pkg}"
            git checkout master > /dev/null 2>&1
            git pull -q > /dev/null
            __aur__pop

            _aur_needs_update ${pkg}
            case $? in
                0)
                    needs_update="$needs_update $pkg"
                    _aur_print_version ${pkg} \
                        $(_aur_local_ver ${pkg}) \
                        $(_aur_remote_ver ${pkg})
                ;;
                1)
                    _aur_print_version ${pkg} $(_aur_local_ver ${pkg})
                ;;
            esac
        else
            __dotsan__warn "${pkg} not installed via AUR"
        fi
    done

    if [[ "${needs_update}" == "" ]]; then
        echo "No updates available"
        return 0
    fi

    if [[ "${yes}" == "" ]]; then
        echo
        echo "The following packages have updates available:"
        for pkg in ${needs_update}; do
            _aur_print_version ${pkg} \
                $(_aur_local_ver ${pkg}) \
                $(_aur_remote_ver ${pkg})
        done

        echo
        read -p "==> install updates? [y/n]: " -r
    fi

    if [[ "${yes}" != "" || $REPLY =~ ^[Yy]$ ]]; then
        built_pkgs=""

        for pkg in ${needs_update}; do
            _aur_build ${pkg}
            if [ "$?" == "0" ]; then
                built_pkgs="${built_pkgs} ${pkg}"
            else
                __dotsan__warn "${pkg} failed to build"
            fi
        done

        if [ "${built_pkgs}" != "" ]; then
            echo "Acquiring elevated privileges"
            sudo echo "Granted"
            if [ "$?" != "0" ]; then
                echo "Failed to elevate privileges, exiting"
                return 1
            fi
            for pkg in ${built_pkgs}; do
                _aur_install_pkg ${pkg}
            done
        fi
    fi
}

#
# Check if $1 has an update remotely
# $? == 1 Up to date
# $? == 0 Update available
# $? == 2 Partial install
#
function _aur_needs_update {
    local installed=$(_aur_local_ver $1)
    if [ "${installed}" == "" ]; then
        return 2
    fi

    local remote=$(_aur_remote_ver $1)
    if [ "$installed" != "$remote" ]; then
        return 0
    else
        return 1
    fi
}

#
# Print a colored version number printout to the terminal
# print_version (pkg name) (installed version) [remote version]
#
function _aur_print_version {
    local C0=$'\e[0m'
    local C1=$'\e[34m'
    local C2=$'\e[33m'
    local C3=$'\e[32m'

    if [[ "$3" == "" ]]; then
        echo "$C3[OK] $C1$1$C0: $C3$2$C0"
    else
        echo "$C2[UP] $C1$1$C0: $C2$2$C0 => $C3$3$C0"
    fi
}

#
# Retrieve the locally installed version of $1
# stdout > version reported by pacman
#
function _aur_local_ver {
    local pacman_version=$(pacman -Q $1 2>/dev/null)
    if [[ "$?" == "0" ]]; then
        echo ${pacman_version} | awk '{ print $2 }'
    fi
}

#
# Get the version number of an AUR package describe in PKGBUILD for $1
# stdout > AUR PKGBUILD version
#
function _aur_remote_ver {
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

#
# Build the given AUR package
#
function _aur_build {
    __aur__push "$1"
    makepkg -s
    mk_rc="$?"
    __aur__pop
    return ${mk_rc}
}

#
# Build and install the given package
#
function _aur_install_pkg {
    __aur__push "$1"
    remote_version=$(_aur_remote_ver $1)
    pkg_path=$(ls -la | grep "${remote_version}" | head -n 1 | awk '{print $9}')
    sudo pacman -U ${pkg_path} --needed --noconfirm
    __aur__pop
}

#
# Search the AUR for $1
#
function _aur_search {
    curl -s "https://aur.archlinux.org/rpc.php?v=5&type=search&arg=$1" | \
        python "$__dotsan__home/bash/pac/aur_search.py"
}

function _aur_clean {
    local pkgs="$1"
    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            __aur__push "${pkg}"
            pwd
            git checkout master
            git clean -fdx
            __aur__pop
        else
            __dotsan__warn "${pkg} was not found in the AUR cache"
        fi
    done
}
