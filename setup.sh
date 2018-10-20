#! /bin/bash


__dotsan__home="$HOME/.sanity"
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

# protective symlink generation
function __dotsan__link() {
    module="$1"
    source="$2"
    link_loc="$HOME/$3"
    link_target="$__dotsan__home/$module/$source"

    if [ -e "$link_loc" ]; then
        existing_link_target=$(readlink ${link_loc})

        if [ "$existing_link_target" == "$link_target" ]; then
            echo "$link_loc target is identical"
            return
        else
            echo "$link_loc overwriting target"
        fi
    fi

    ln -vfs "$link_target" "$link_loc"
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
    pacman -Q | grep "^${1} " > /dev/null
    return $?
}

#
# Module Support
#
# modules are initialized as such:
# $ source ./[module_name]/init.sh
# $ __dotsan__[module_name]__init check
# $ __dotsan__[module_name]__init build
# $ __dotsan__[module_name]__init install
#
for module_name in $(ls -l "$__dotsan__home" | grep ^d | awk '{ print $9}'); do
    init_func_name="__dotsan__${module_name}__init"

    if [ -e "$__dotsan__home/$module_name/init.sh" ]; then
        echo
        __dotsan__info "Loading $module_name"
        source "$module_name/init.sh"

        # get required and suggested packages from the module
        required=$(eval "${init_func_name}" check required)
        suggested=$(eval "${init_func_name}" check suggested)

        missing=""
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

dot_link bashrc.sh .bashrc
dot_link gitconfig .gitconfig
dot_link gitignore .gitignore
dot_link xmodmap .Xmodmap
dot_link xprofile .xprofile
dot_link ctags .ctags

# link up awesome configs
if command -v awesome > /dev/null; then
    mkdir -p "$HOME/.config/awesome/widgets"
    mkdir -p "$HOME/.config/awesome/assets"
    mirror_link awesome .config/awesome
else
    echo "Awesome WM not found, skipping"
fi

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

# rofi
if command -v rofi > /dev/null; then
    mkdir -p "$HOME/.config/rofi"
    dot_link rofi.config .config/rofi/config
    dot_link rofi-theme.rasi .config/rofi/dotsanity.rasi
else
    echo "Rofi not found, skipping"
fi

#
# Set up Vim
#
dot_link vimrc .vimrc
if [ ! -e "$HOME/.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
fi
vim +PluginInstall +qall

# if there is a setup in private, call it
if [ -e "$DOTHOME/private/setup.sh" ]; then
    echo 'Running private setup...'
    source $DOTHOME/private/setup.sh
fi

