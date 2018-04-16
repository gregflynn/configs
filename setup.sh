#! /bin/bash

DOTHOME="$HOME/.sanity"

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

dot_link bashrc.sh .bashrc
dot_link gitconfig .gitconfig
dot_link gitignore .gitignore
dot_link xmodmap .Xmodmap
dot_link xprofile .xprofile
dot_link ctags .ctags

# link up awesome configs
if command -v awesome > /dev/null; then
    mkdir -p "$HOME/.config/awesome/widgets"
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

# XFCE4 Terminal
if command -v xfce4-terminal > /dev/null; then
    mkdir -p "$HOME/.config/xfce4/terminal"
    dot_link xfce4-terminal.rc .config/xfce4/terminal/terminalrc
else
    echo "Xfce4 Terminal not found, skipping"
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

