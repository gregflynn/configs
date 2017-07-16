#! /bin/bash
AUR_HOME="$HOME/aur"

function pac() {
  if [[ "$2" == "-"* ]]; then
    flag="$2"
    pkgs="${@:3}"
    pkg="$3"
  else
    flag=""
    pkgs="${@:2}"
    pkg="$2"
  fi
  case $1 in
    update)
      if [[ "$flag" == "-aur" ]]; then
        echo "Updating AUR packages..."
        aur_update
      else
        echo "Updating..."
        sudo pacman -Syy
        if [[ "$?" == "0" ]]; then
          sudo pacman -Syu
        fi
      fi
    ;;
    install)
      if [[ "$pkg" == "" ]]; then
        echo "Usage: pac install [-aur] pkg1 [pkg2...]"
        return
      fi

      if [[ "$flag" == "-aur" ]]; then
        echo "Installing $pkg from the AUR..."
        aur_install $pkg
      else
        echo "Installing $pkgs..."
        sudo pacman -S $pkgs
      fi
    ;;
    remove)
      if [[ "$pkg" == "" ]]; then
        echo "Usage: pac remove pkg1 [pkg2...]"
        return
      fi

      echo "Removing $pkgs..."
      sudo pacman -Rs $pkgs
      if [[ "$?" == "0" ]]; then
        for pkg in "$pkgs"; do
          if [ -e "$AUR_HOME/$pkg" ]; then
            echo "Deleting $AUR_HOME/$pkg"
            rm -rf "$AUR_HOME/$pkg"
          fi
        done
      fi
    ;;
    search)
      if [[ "$pkg" == "" ]]; then
        echo "Usage: pac search [-l|-p] pkg1"
        return
      fi

      if [[ "$flag" != "-l" ]]; then
        echo "Official Repos:"
        echo "==============="
        remote=`pacman -Ss $pkg`
        if [ "$remote" == "" ]; then
          echo "Not Found"
        else
          echo "$remote"
        fi
      fi

      if [[ "$flag" != "-p" && "$flag" != "-l" ]]; then
        echo ""
        echo "Arch User Repository:"
        echo "====================="
        aur_search $pkg
      fi

      echo ""
      echo "Installed Packages:"
      echo "==================="
      locals=`pacman -Qs $pkg`
      if [ "$locals" == "" ]; then
        echo "Not Found"
      else
        echo "$locals"
      fi
    ;;
    list)
      case $2 in
        aur)
          echo "AUR Installed Packages"
          echo -n "======================"
          ll $AUR_HOME | awk '{ print $9}'
        ;;
        all)
          echo "All Installed Packages"
          echo -n "======================"
          pacman -Q
        ;;
        installed)
          echo "Explicitly Installed Packages"
          echo "============================="
          pacman -Qen
        ;;
        orphans)
          echo "Orphaned Packages"
          echo "================="
          pacman -Qtdq
        ;;
        *)
          echo "Usage: pac list [all|aur|installed|orphans]"
        ;;
      esac
    ;;
    *)
    echo "Usage: pac [update|install|remove|search|list] [package_name]"
    ;;
  esac
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
  git pull > /dev/null
  lver=`installed_version $1`
  aver=`aur_version $1`

  C0=$'\e[0m'
  C1=$'\e[34m'
  C2=$'\e[31m'
  C3=$'\e[32m'
  if [ "$lver" != "$aver" ]; then
    echo "Upgrading $C1$1$C0: $C2$lver$C0 => $C3$aver$C0"
    git checkout master
    git clean -fd
    makepkg -si
  else
    echo "Already up-to-date: $C1$1$C0: $C3$lver$C0"
  fi
  popd > /dev/null
}

function aur_install() {
  pkg_name="$1"
  mkdir -p "$AUR_HOME"
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
  ver=`cat $pkgbuild | grep "pkgver=" | sed 's/pkgver=//' | sed 's/"//g' | sed "s/'//g"`
  rel=`cat $pkgbuild | grep "pkgrel=" | sed 's/pkgrel=//' | sed 's/"//g' | sed "s/'//g"`
  epo=`cat $pkgbuild | grep "epoch=" | sed 's/epoch=//' | sed 's/"//g' | sed "s/'//g"`

  # needed for lain-git
  if [[ $ver == *"\$pkgcom"* ]]; then
    pkgcom=`cat $pkgbuild | grep "pkgcom=" | sed 's/pkgcom=//' | sed 's/"//g' | sed "s/'//g"`
    ver=$(echo $ver | sed "s/\$pkgcom/$pkgcom/")
  fi

  if [[ $ver == *"\$pkgsha"* ]]; then
    pkgsha=`cat $pkgbuild | grep "pkgsha=" | sed 's/pkgsha=//' | sed 's/"//g' | sed "s/'//g"`
    ver=$(echo $ver | sed "s/\$pkgsha/$pkgsha/")
  fi

  base_version="$ver-$rel"
  if [ "$epo" != "" ]; then
    echo "$epo:$base_version"
  else
    echo "$base_version"
  fi
}

function installed_version() {
  pacman_version=`pacman -Q $1`
  if [ "$?" == "0" ]; then
    echo $pacman_version | awk '{ print $2 }'
  fi
}

function aur_search() {
  curl -s "https://aur.archlinux.org/rpc.php?v=5&type=search&arg=$1" | \
    python "$HOME/.sanity/bashrc_helpers/aur_search.py"
}
