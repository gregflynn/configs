#!/usr/bin/env bash


__dotsan__home="$HOME/.sanity"
__dotsan__lock="$__dotsan__home/x11/dist/i3lock.sh"
__dotsan__wallpaper="$__dotsan__home/private/wallpapers/light_lanes.png"
__dotsan__modules=$(ls -l "$__dotsan__home" | grep ^d | awk '{ print $9}')
source "$__dotsan__home/bash/colors.sh"


function __dotsan__inject {
    module="$1"
    dist="$__dotsan__home/$module/dist"
    infile="$__dotsan__home/$module/$2"

    if [[ "$3" == "" ]]; then
        outfile="$dist/$2"
    else
        outfile="$dist/$3"
    fi

    mkdir -p ${dist}

    infile_short=$(echo ${infile} | sed "s;${HOME};~;g")
    outfile_short=$(echo ${outfile} | sed "s;${HOME};~;g")

    cat ${infile} \
        | sed "s;{DS_HOME};${__dotsan__home};g" \
        | sed "s;{DS_LOCK};${__dotsan__lock};g" \
        | sed "s;{DS_WALLPAPER};${__dotsan__wallpaper};g" \
        | sed "s;{DS_BACKGROUND};${__dotsan__hex__background};g" \
        | sed "s;{DS_BLACK};${__dotsan__hex__black};g" \
        | sed "s;{DS_BLUE};${__dotsan__hex__blue};g" \
        | sed "s;{DS_CYAN};${__dotsan__hex__cyan};g" \
        | sed "s;{DS_GREEN};${__dotsan__hex__green};g" \
        | sed "s;{DS_GRAY};${__dotsan__hex__gray};g" \
        | sed "s;{DS_ORANGE};${__dotsan__hex__orange};g" \
        | sed "s;{DS_PURPLE};${__dotsan__hex__purple};g" \
        | sed "s;{DS_RED};${__dotsan__hex__red};g" \
        | sed "s;{DS_WHITE};${__dotsan__hex__white};g" \
        | sed "s;{DS_YELLOW};${__dotsan__hex__yellow};g" \
        > ${outfile}
}

function __dotsan__syslink {
    module="$1"
    source="$2"
    link_loc="$3"
    link_target="$__dotsan__home/$module/$source"

    if [[ -e "$link_loc" ]]; then
        existing_link_target=$(readlink ${link_loc})

        if [[ "$existing_link_target" == "$link_target" ]]; then
            return
        else
            echo "$link_loc: updated target"
        fi
    fi

    ln -vfs "$link_target" "$link_loc"
}

function __dotsan__link {
    link_loc="$HOME/$3"
    __dotsan__syslink ${1} ${2} ${link_loc}
}

function __dotsan__mirror__syslink {
    module=${1}
    mirror=${2}
    target_dir=${3}
    clean=${4}

    source_dir="$__dotsan__home/$module/$mirror"
    diff_result=$(diff -r ${source_dir} ${target_dir} 2>&1)
    broken_links=$(echo -e "$diff_result" \
        | grep "No such file or directory" \
        | awk '{ print $2 }' \
        | sed 's;:;;g')

    # clear out broken links
    for broken_link in ${broken_links}; do
        rm ${broken_link}
    done

    if [[ "$broken_links" != "" ]]; then
        diff_result=$(diff -r ${source_dir} ${target_dir} 2>&1)
    fi

    missing_links=$(echo -e "$diff_result" \
        | grep "Only in $source_dir" \
        | awk '{ print $3$4 }' \
        | sed 's;:;\/;g')

    for new_link in ${missing_links}; do
        # new_link if the full system path of the file being linked to in
        # __dotsan__home
        if [[ -d ${new_link} ]]; then
            # don't create directories
            continue
        else
            local_link="${new_link#$source_dir}"
            __dotsan__syslink ${module} "$mirror$local_link" "$target_dir$local_link"
        fi
    done

    if [[ "$clean" == "clean" ]]; then
        untracked_files=$(echo -e "$diff_result" \
            | grep "Only in $target_dir" \
            | awk '{ print $3$4 }' \
            | sed 's/:/\//g')
        for untracked in ${untracked_files}; do
            rm ${untracked}
        done
    fi
}

function __dotsan__mirror__link {
    target_dir=${HOME}/${3}
    __dotsan__mirror__syslink ${1} ${2} ${target_dir} ${4}
}

function __dotsan__is__installed {
    if command -v pacman > /dev/null; then
        pacman -Q | grep "^${1} " > /dev/null
        return $?
    else
        # always fallback to a debian based distribution
        dpkg -l | grep " ${1} " > /dev/null
        return $?
    fi
}

function __dotsan__setup__echo {
    local status="$1"
    local color="$2"
    local module="$3"
    local extra_info="$4"

    __dsc__echo "[${status}]" ${color} p p 1
    __dsc__echo " ${module} " blue p p 1
    __dsc__echo "${extra_info}" ${color}
}

function __dotsan__requirements {
    local init_func_name="$1"
    local missing=""

    if [[ $(whoami) == "root" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        local clionly=$(eval "${init_func_name}" check clionly)

        if [[ "$clionly" == "" ]]; then
            echo "Module not enabled in CLI-Only environment."
            return 1
        fi
    fi

    # get required packages from the module
    required=$(eval "${init_func_name}" check required)

    for pkg in ${required}; do
        if ! __dotsan__is__installed ${pkg}; then
            missing="$missing $pkg"
        fi
    done

    if [[ "$missing" != "" ]]; then
        echo "Missing Packages: ${missing}"
        return 1
    fi
}

function __dotsan__install__module {
    local module_name="$1"
    local init_file="$__dotsan__home/$module_name/init.sh"
    local init_func_name="__dotsan__${module_name}__init"

    if [[ -e "$init_file" ]]; then
        source "$init_file"
        local requirements_message="$(__dotsan__requirements ${init_func_name})"

        if [[ "$requirements_message" != "" ]]; then
            __dotsan__setup__echo 'SK' 'yellow' ${module_name} "${requirements_message}"
            return 0
        fi

        if ! eval "${init_func_name}" build; then
            __dotsan__setup__echo 'ER' 'red' ${module_name} "failed to build"
        else
            if eval "${init_func_name}" install; then
                __dotsan__setup__echo 'IN' 'green' ${module_name}
            else
                __dotsan__setup__echo 'ER' 'red' ${module_name} "install failed"
            fi
        fi
    fi
}


if [[ "$1" != "" ]]; then
    __dotsan__modules=$(echo "$__dotsan__modules" | grep "$1")
fi

for module_name in ${__dotsan__modules}; do
    __dotsan__install__module ${module_name}
done
