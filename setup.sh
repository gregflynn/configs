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

# before anything, make sure we're up to date
git pull
if [ -e "private/" ]; then
  pushd private > /dev/null
  git pull
  popd > /dev/null
fi

# save out where the hell we are
pushd `dirname $0` > /dev/null
DOTSANTIY=`pwd -P`
popd > /dev/null

if [ -e "$DOTHOME" ]; then
  LINK=`readlink -f $DOTHOME`
  echo "Exists: $DOTHOME -> $LINK"
else
  ln -vfs $DOTSANITY $DOTHOME
fi

dot_link bashrc .bashrc
dot_link gitconfig .gitconfig
dot_link gitignore .gitignore

if [ type xmodmap > /dev/null 2>&1 ]; then
  dot_link xmodmap .Xmodmap
  dot_link xinitrc .xinitrc
else
  echo "xmodmap not installed, skipping..."
fi

# atom's many configs
if [ type atom > /dev/null 2>&1 ]; then
  dot_link atom/config.cson .atom/config.cson
  dot_link atom/keymap.cson .atom/keymap.cson
  dot_link atom/snippets.cson .atom/snippets.cson
  dot_link atom/styles.less .atom/styles.less
else
  echo "atom not installed, skipping..."
fi

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
