#! /bin/bash

DOTHOME="~/.sanity"

# protective symlink generation
function dot_link() {
  SOURCE="$1"
  TARGET="$2"
  POST=""
  if [ "$3" != "" ]; then
    POST="private/"
  fi
  if [ -e "$TARGET" ]; then
    echo "$TARGET exists"
  else
    ln -vfs $DOTHOME/$POST$SOURCE $TARGET
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

dot_link bashrc ~/.bashrc

dot_link vimrc ~/.vimrc

dot_link gitignore ~/.gitignore

# if there is a setup in private, call it
if [ -e "private/setup.sh" ]; then
  ./private/setup.sh
fi
