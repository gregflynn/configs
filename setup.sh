#! /bin/bash

# protective symlink generation
function dot_link() {
  SOURCE="$1"
  TARGET="$2"
  if [ -e "$TARGET" ]; then
    echo "$TARGET exists"
  else
    ln -vfs $DOTSANTIY/$SOURCE $TARGET
  fi
}

# save out where the hell we are
pushd `dirname $0` > /dev/null
DOTSANTIY=`pwd -P`
popd > /dev/null

dot_link bashrc ~/.bashrc

dot_link vimrc ~/.vimrc

dot_link gitconfig ~/.gitconfig

dot_link gitignore ~/.gitignore

# TODO: i need a way to call into symlinking private data, sorry githubbers
