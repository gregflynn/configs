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
    # TODO
    return 0
}

dot_link bashrc.sh .bashrc
dot_link gitconfig .gitconfig
dot_link gitignore .gitignore
dot_link xmodmap .Xmodmap
dot_link xprofile .xprofile

# link up awesome configs
mkdir -p ~/.config/awesome
mkdir -p ~/.config/awesome/widgets
dot_link awesome/rc.lua .config/awesome/rc.lua
dot_link awesome/rules.lua .config/awesome/rules.lua
dot_link awesome/theme.lua .config/awesome/theme.lua
dot_link awesome/widgets/battery.lua .config/awesome/widgets/battery.lua
dot_link awesome/widgets/clock.lua .config/awesome/widgets/clock.lua
dot_link awesome/widgets/cpugraph.lua .config/awesome/widgets/cpugraph.lua
dot_link awesome/widgets/cputemp.lua .config/awesome/widgets/cputemp.lua
dot_link awesome/widgets/diskusage.lua .config/awesome/widgets/diskusage.lua
dot_link awesome/widgets/gpmdp.lua .config/awesome/widgets/gpmdp.lua
dot_link awesome/widgets/memory.lua .config/awesome/widgets/memory.lua
dot_link awesome/widgets/volume.lua .config/awesome/widgets/volume.lua
dot_link awesome/widgets/weather.lua .config/awesome/widgets/weather.lua

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

