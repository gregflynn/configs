#! /bin/bash


function aur {
    local pkgs="${@:2}"

    case $1 in
        update)
            if [ "${pkgs}" == "" ]; then
                pkgs=$(ls ${__aur__home} | xargs)
            fi
            _aur_update "${pkgs}"
        ;;
        install)
            if [ "${pkgs}" == "" ]; then
                echo "Usage: aur install pkg1 [pkg2...]"
                return
            fi
            _aur_install ${pkgs}
        ;;
        remove)
            if [ "${pkgs}" == "" ]; then
                echo "Usage: aur remove pkg1 [pkg2...]"
                return
            fi

            for pkg in ${pkgs}; do
                if __pac__is__aur__pkg ${pkg}; then
                    sudo pacman -Rs ${pkg}
                    if [ "$?" == "0" ]; then
                        rm -rf "${__aur__home}/${pkg}"
                    fi
                else
                    __dotsan__warn "${pkg} not an AUR package"
                fi
            done
        ;;
        search)
            if [ "${pkgs}" == "" ]; then
                echo "Usage: aur search pkg1"
                return 0
            fi
            _aur_search "${pkgs}"
        ;;
        list)
            ll ${__aur__home} | awk '{ print $9}'
        ;;
        clean)
            _aur_clean ${pkgs}
        ;;
        inspect)
            if __pac__is__aur__pkg ${pkgs}; then
                _aur_pushd ${pkgs}
            else
                __dotsan__warn "${pkgs} is not installed from the AUR"
            fi
        ;;
        web)
            xdg-open "https://aur.archlinux.org/"
        ;;
        *)
            echo "Usage: aur [update|install|remove|search|list|clean] package names"
        ;;
    esac
}

function _aur_pushd {
    pushd ${__aur__home}/$1 > /dev/null
}

function _aur_popd() {
    popd > /dev/null
}

#
# Install a package from the AUR
#
function _aur_install {
    local pkgs="$1"
    mkdir -p "${__aur__home}"

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
            if [ "$?" == "0" ]; then
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
    local needs_update=""

    for pkg in ${pkgs}; do
        if __pac__is__aur__pkg ${pkg}; then
            _aur_pushd ${pkg}
            git checkout master > /dev/null 2>&1
            git pull -q > /dev/null
            _aur_popd

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

    if [ "${needs_update}" == "" ]; then
        echo "No updates available"
        return 0
    fi

    echo
    echo "The following packages have updates available:"
    for pkg in ${needs_update}; do
        _aur_print_version ${pkg} \
            $(_aur_local_ver ${pkg}) \
            $(_aur_remote_ver ${pkg})
    done

    echo
    read -p "==> Install updates? [y/n] " -r

    if [[ $REPLY =~ ^[Yy]$ ]]; then
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

    if [ "$3" == "" ]; then
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
    if [ "$?" == "0" ]; then
        echo ${pacman_version} | awk '{ print $2 }'
    fi
}

#
# Get the version number of an AUR package describe in PKGBUILD for $1
# stdout > AUR PKGBUILD version
#
function _aur_remote_ver {
    local pkgbuild="${__aur__home}/$1/PKGBUILD"
    if [ ! -e ${pkgbuild} ]; then return 1; fi

    source "$pkgbuild"

    local base_version="$pkgver-$pkgrel"
    if [ "$epoch" != "" ]; then
        echo "$epoch:$base_version"
    else
        echo "$base_version"
    fi
}

#
# Build the given AUR package
#
function _aur_build {
    _aur_pushd $1
    makepkg -s
    mk_rc="$?"
    _aur_popd
    return ${mk_rc}
}

#
# Build and install the given package
#
function _aur_install_pkg {
    _aur_pushd $1
    remote_version=$(_aur_remote_ver $1)
    pkg_path=$(ls -la | grep "${remote_version}" | head -n 1 | awk '{print $9}')
    sudo pacman -U ${pkg_path} --needed --noconfirm
    _aur_popd
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
            _aur_pushd ${pkg}
            pwd
            git checkout master
            git clean -fdx
            _aur_popd
        else
            __dotsan__warn "${pkg} was not found in the AUR cache"
        fi
    done
}
