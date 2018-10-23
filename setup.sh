#!/usr/bin/env bash


__dotsan__home="$HOME/.sanity"
__dotsan__modules=$(ls -l "$__dotsan__home" | grep ^d | awk '{ print $9}')
DOTHOME="$__dotsan__home"

source "$__dotsan__home/colors.sh"


# protective symlink generation
function dot_link() {
    SOURCE="$1"
    POST=""
    if [ "$3" != "" ]; then
        POST="private/"
    fi
    if [ -e "$HOME/$2" ]; then
        echo "$HOME/$2 exists"
    else
        ln -vfs $DOTHOME/$POST$SOURCE $HOME/$2
    fi
}

function __dotsan__syslink() {
    module="$1"
    source="$2"
    link_loc="$3"
    link_target="$__dotsan__home/$module/$source"

    if [ -e "$link_loc" ]; then
        existing_link_target=$(readlink ${link_loc})

        if [ "$existing_link_target" == "$link_target" ]; then
#            echo "$link_loc target is identical"
            return
        else
            echo "$link_loc: updated target"
        fi
    fi

    ln -vfs "$link_target" "$link_loc"
}

function __dotsan__link() {
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

    if [ "$broken_links" != "" ]; then
        diff_result=$(diff -r ${source_dir} ${target_dir} 2>&1)
    fi

    missing_links=$(echo -e "$diff_result" \
        | grep "Only in $source_dir" \
        | awk '{ print $3$4 }' \
        | sed 's;:;\/;g')

    for new_link in ${missing_links}; do
        # new_link if the full system path of the file being linked to in
        # __dotsan__home
        if [ -d ${new_link} ]; then
            # create missing directories
            mkdir -p ${new_link}
        else
            local_link="${new_link#$source_dir}"
            __dotsan__syslink ${module} "$mirror$local_link" "$target_dir$local_link"
        fi
    done

    if [ "$clean" == "clean" ]; then
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
    __dotsan__mirror__syslink ${1} ${2} ${target_dir}
}

# mirror a dotsan directory in symlinks
function mirror_link() {
    dotsource="$DOTHOME/$1"
    dstprefix="$HOME/$2"
    for new_file in $(diff -r $dotsource $dstprefix | grep "Only in $dotsource" | awk '{ print $3$4 }' | sed 's/:/\//g'); do
        src="$new_file"
        dst="$dstprefix${src#$dotsource}"

        if [[ -f "$src" ]]; then
            ln -vfs "$src" "$dst"
        fi
    done
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

function __dotsan__requirements {
    init_func_name="$1"
    missing=""

    # get required and suggested packages from the module
    required=$(eval "${init_func_name}" check required)
    suggested=$(eval "${init_func_name}" check suggested)

    for pkg in ${required}; do
        if ! __dotsan__is__installed ${pkg}; then
            __dotsan__error "${pkg} is not installed"
            missing="$missing $pkg"
        fi
    done

    for pkg in ${suggested}; do
        if ! __dotsan__is__installed ${pkg}; then
            __dotsan__warn "${pkg} is not installed"
        fi
    done

    if [ "$missing" != "" ]; then
        return 1
    fi
}

#
# Module Support
#
for module_name in ${__dotsan__modules}; do
    init_file="$__dotsan__home/$module_name/init.sh"
    init_func_name="__dotsan__${module_name}__init"

    if [ -e "$init_file" ]; then
        echo
        __dotsan__info "Loading $module_name"
        source "$init_file"

        __dotsan__requirements ${init_func_name}
        if [ "$?" != "0" ]; then
            __dotsan__warn "${module_name} Skipped"
            continue
        fi

        if eval "${init_func_name}" build; then

            if eval "${init_func_name}" install; then
                __dotsan__success "Installed ${module_name}"
            else
                __dotsan__error "Install Failed ${module_name}"
                exit 1
            fi
        else
            __dotsan__error "Build Failed ${module_name}"
            exit 1
        fi
    fi
done

dot_link xmodmap .Xmodmap
dot_link xprofile .xprofile
dot_link ctags .ctags

# link up visual studio code
if command -v code > /dev/null; then
    mkdir -p "$HOME/.config/Code/User/snippets"
    mirror_link vscode/User .config/Code/User
    # pushd vscode > /dev/null && python sync.py && popd > /dev/null
else
    echo "Visual Studio Code not found, skipping"
fi

# Tilix Terminal
if command -v tilix > /dev/null; then
    dconf load /com/gexperts/Tilix/ < tilix.dconf
else
    echo "Tilix not found, skipping"
fi

# tmux
dot_link tmux.conf .tmux.conf
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "tmux TPM already installed, skipping"
fi

#
# Set up Vim
#
dot_link vimrc .vimrc
if [ ! -e "$HOME/.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
fi
vim +PluginInstall +qall
