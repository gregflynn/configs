#! /bin/bash

function pac() {
  case $1 in
    update)
      echo "Updating..."
      sudo pacman -Syy
      sudo pacman -Syu
    ;;
    install)
      echo "Installing $2..."
      sudo pacman -S $2
    ;;
    remove)
      echo "Removing $2..."
      sudo pacman -R $2
    ;;
    search)
        echo "Remote Search:"
        pacman -Ss $2
        echo "-------------"
        echo "Local Search:"
        pacman -Qs $2
    ;;
    *)
    echo "Usage: pac [update|install|remove] [package_name]"
    ;;
  esac
}

AUR_HOME="$HOME/aur"

function aur() {
  case $1 in
    update)
      if [ "$2" == "" ]; then
        echo "Updating all AUR packages..."
      else
        echo "Updating $2 from AUR..."
      fi
      aur_update $2
      return 0
    ;;
    install)
      echo "Installing $2 from AUR..."
      if [ "$2" != "" ]; then
        aur_install $2
        return 0
      fi
    ;;
    remove)
      echo "Removing $2..."
      if [ "$2" != "" ]; then
        aur_remove $2
        return 0
      fi
    ;;
  esac
  echo "Usage: aur [update|install|remove] [package_name]"
}

function aur_update() {
  if [ "$1" == "" ]; then
    for pkg in `ls $AUR_HOME | xargs`; do
      aur_update_single $pkg
    done
  else
    aur_update_single $1
  fi
}

function aur_update_single() {
  if [ ! -e $AUR_HOME/$1 ]; then
    echo "Couldn't find checkout for $1..."
    echo "Installing $1..."
    aur_install $1
    return 0
  fi

  home="$AUR_HOME/$1"
  pushd $home > /dev/null
  git pull
  lver=`installed_version $1`
  aver=`aur_version $1`

  if [ "$lver" != "$aver" ]; then
    echo "Upgrading $1: $lver => $aver"
    makepkg -si
  else
    echo "Already up-to-date: $1: $lver"
  fi
}

function aur_install() {
  pkg_name="$1"
  clone_dir="$AUR_HOME/$pkg_name"

  # make sure that package doesn't exist
  if [ -e $clone_dir ]; then
    echo "Package already checked out: $pkg_name"
    echo "Updating $pkg_name..."
    aur_update_single $pkg_name
    return 0
  fi

  # clone the aur repo
  pushd $AUR_HOME > /dev/null
  git clone aur:$pkg_name $clone_dir
  popd > /dev/null
  if [ "$?" != "0" ]; then
    echo "AUR package not found: $pkg_name"
    return 1
  fi

  # run makepkg
  pushd $AUR_HOME/$1 > /dev/null
  makepkg -si
  popd > /dev/null
}

function aur_version() {
  pkgbuild="$AUR_HOME/$1/PKGBUILD"
  if [ ! -e $pkgbuild ]; then
    return 1
  fi
  ver=`cat $pkgbuild | grep "pkgver=" | sed 's/pkgver=//' | sed 's/"//g'`
  rel=`cat $pkgbuild | grep "pkgrel=" | sed 's/pkgrel=//' | sed 's/"//g'`
  echo "$ver-$rel"
}

function installed_version() {
  pacman_version=`pacman -Q $1`
  if [ "$?" == "0" ]; then
    echo $pacman_version | awk '{ print $2 }'
  fi
}
