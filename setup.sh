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

# link up awesome configs
mkdir -p ~/.config/awesome
mkdir -p ~/.config/awesome/widgets
mirror_link awesome .config/awesome

# link up termite
mkdir -p ~/.config/termite
dot_link termite .config/termite/config

#
# Set up Vim
#
dot_link vimrc .vimrc
if [ ! -e "$HOME/.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

# if there is a setup in private, call it
if [ -e "private/setup.sh" ]; then
    source private/setup.sh
fi

