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

dot_link vimrc .vimrc

dot_link gitignore .gitignore

# if there is a setup in private, call it
if [ -e "private/setup.sh" ]; then
  source private/setup.sh
fi
