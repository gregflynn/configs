#! /bin/bash

{IS_AUR_PKG}
__aur__home="{AUR_HOME}"
__pac__cache="{PACMAN_CACHE}"
__pac__log="{PACMAN_LOG}"
__pac__watch__list="{PACKAGE_WATCH_LIST}"


function __pac__hl {
    __dsc__ncho "$1" yellow
}


function __pac__opt {
    __dsc__ncho "$1" p p i
}


function __pac__help {
    local cmd=$(__pac__hl COMMAND)
    local opt_pkg=$(__pac__opt "package")
    local opt_pkgs=$(__pac__opt "package [package2, ...]")

    echo "    Arch Linux Pacman Wrapper

    $(echo -en $'\uf061') pac $cmd $(__pac__opt "[package [package2 ...]]")

    General $cmd options

        $(__pac__hl help)
            - show this help message

        $(__pac__hl install) $opt_pkgs
            - install one or more packages from the official repositories

        $(__pac__hl remove) $opt_pkgs
            - remove one or more installed packages

        $(__pac__hl update)
            - update package repositories and optionally install new versions

    Search $cmd options

        $(__pac__hl search) $opt_pkg
            - Search the official repositories

        $(__pac__hl web) $(__pac__opt "[package]")
            - Open and search the Arch Linux package web interface

    Maintenance $cmd options

        $(__pac__hl history) $opt_pkg
            - show package history for the given package

        $(__pac__hl info) $opt_pkg
            - show package information

        $(__pac__hl list) $(__pac__opt "[explicit|orphans] [filter]")
            - list installed packages, optionally filtered by status or name

        $(__pac__hl cache) $(__pac__opt "[info|prune|revert|show]")
            - show and manage the pacman cache
    "
}


function __pac {
    local pkgs="${@:2}"

    case $1 in
        cache)
            case $2 in
                prune)  __pac__cache__prune  ;;
                revert) __pac__cache__revert $3 $4 ;;
                show)   __pac__cache__show   $3 ;;
                info)   __pac__cache__summary ;;
                *)
                    if [[ "$2" != "" ]]; then
                        __dsc__error "Unknown option: ${2}"
                    fi
                ;;
            esac
        ;;
        history) __pac__history "$pkgs" ;;
        info)    __pac__info    "$pkgs" ;;
        install) __pac__install "$pkgs" ;;
        list)    __pac__list    ${pkgs} ;;
        remove)  __pac__remove  "$pkgs" ;;
        search)  __pac__search  "$pkgs" ;;
        update)  __pac__update  ;;
        web)     __pac__web     "$pkgs";;
        *)       __pac__help    ;;
    esac
}


#
# General
#


function __pac__pm {
    sudo pacman --color auto $@
}


function __pac__install {
    local pkgs="$1"

    if [[ "$pkgs" == "" ]]; then
        __dsc__error "No package specified for installation"
        return 1
    fi

    __pac__pm -S ${pkgs}
}


function __pac__update {
    # update the package database
    __pac__pm -Syy

    if [[ "$?" == "0" ]]; then

        # check for watched packages
        local searchstr=$(echo "$__pac__watch__list" | sed 's/ /\\\|/g')
        local watched_updates=$(pacman -Qu | grep "$searchstr")
        if [[ "$watched_updates" != "" ]]; then
            echo
            __dsc__warn "Watched packages updated"
            while IFS=$'\n' read -r pkgstr; do
                IFS=', ' read -r -a pkgarr <<< "$pkgstr"
                __dsc__line "[UP] " yellow ${pkgarr[0]} blue ": " white ${pkgarr[1]} yellow " => " white ${pkgarr[3]} green
            done <<< "$watched_updates"
            echo
        fi

        __pac__pm -Su
    fi
}


function __pac__remove {
    local pkgs="$1"

    if [[ "$pkgs" == "" ]]; then
        __dsc__error "No package specified for removal"
        return 1
    fi

    for pkg in "$pkgs"; do
        if __pac__is__aur__pkg ${pkg}; then
            __dsc__warn "$pkg is installed via the AUR"
        else
            __pac__pm -Rs ${pkg}
        fi
    done
}


#
# Maintenance
#


function __pac__list {
    local pkg="$1"
    local flags=""
    local search="$2"
    local results

    if [[ "$pkg" == "dead" ]]; then
        results=$(grep -vxF -f <(ls $__aur__home) <(pacman -Qmq))
    else
        case ${pkg} in
            explicit) flags="en"  ;;
            orphans)   flags="tdq" ;;
            *) search="$pkg" ;;
        esac

        flags="-Q$flags"
        results="$(pacman ${flags} | awk '{ print $1 }')"
    fi

    if [[ "$search" != "" ]]; then
        results=$(echo "$results" | grep -i ${search})
    fi

    echo "$results"
}


function __pac__info {
    pacman -Qi ${1} --color auto
}


#
# Search
#


function __pac__history {
    local pkg="$1"

    local pacman_history=$(
        cat ${__pac__log} \
        | grep 'installed\|upgraded\|removed' \
        | sed 's/ \[ALPM\] / /g'
    )

    if [[ "$pkg" != "" ]]; then
        pacman_history=$(echo -e "${pacman_history}" | grep "$pkg")
    fi

    echo -e "${pacman_history}"
}


function __pac__search {
    local pkg="$1"

    if [[ "$pkg" == "" ]]; then
        __dsc__error "No search term specified"
        return 1
    fi

    local remote=$(pacman -Ss ${pkgs})
    if [[ "$remote" == "" ]]; then
        echo "Not Found"
    else
        # https://unix.stackexchange.com/a/45954/212439
        local e=$(printf '\033')
        local r="[0m"
        local rc=$(__dsc p p d 1)
        local pc=$(__dsc yellow p p 1)

        echo "$remote" \
                | sed -E "s/^([a-z]*)\/([^ ]*)/$e$pc\2$e$r $e$rc(\1)$e$r/" \
                | __dsc__hl "\[installed\]" green
    fi
}


function __pac__web {
    local url="https://www.archlinux.org/packages/"

    if [[ "$1" == "" ]]; then
        xdg-open "$url"
    else
        xdg-open "$url?q=$1"
    fi
}


#
# Pacman Cache Management
#


function __pac__cache__summary {
    __dsc__echo "Pacman Package Cache" blue p p 1
    __dsc__echo " ${__pac__cache}" green
    __pac__cache__info

    local ignores=$(cat /etc/pacman.conf | grep -v ^# | grep IgnorePkg)
    if [[ "${ignores}" != "" ]]; then
        __dsc__echo "${ignores}" red
    fi
}

function __pac__cache__prune {
    if ! pacman -Q pacman-contrib >/dev/null 2>&1; then
        __dsc__error "pacman-contrib not installed"
        return
    fi

    __pac__cache__info
    echo

    __dsc__info "Removing uninstalled packages..."
    paccache -r -c ${__pac__cache} -u
    echo

    __dsc__info "Removing old packages..."
    paccache -r -c ${__pac__cache} -k 10
    echo

    __pac__cache__info
}


function __pac__cache__revert {
    local pkg="$1"
    local version="$2"

    if [[ "$pkg" == "" ]]; then
        __dsc__error "No package specified"
        return 1
    fi

    if [[ "$version" == "" ]]; then
        pac cache show "${pkg}"
        echo
        read -p "==> revert to: " -r
        version="${REPLY}"
    fi

    if ! [[ -e "${__pac__cache}/${version}" ]]; then
        __dsc__error "${version} not found"
        return 1
    fi

    read -p "==> revert to ${version}? [y/n]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        __pac__pm -U ${__pac__cache}/${version}
    else
        __dsc__echo 'Revert Aborted' yellow
    fi
}


function __pac__cache__show {
    local pkg="$1"

    if [[ "$pkg" == "" ]]; then
        __dsc__error "No package specified"
        return 1
    fi

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


function __pac__cache__info {
    local num_pkgs=$(ls -C ${__pac__cache} | wc -l)
    local cache_size=$(du -h -d 1 ${__pac__cache} | awk '{ print $1 }')
    __dsc__line "${num_pkgs}" green " Cached Packages" blue
    __dsc__line "${cache_size}" green " on disk" blue
}
