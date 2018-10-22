#!/usr/bin/env bash


alias reload='dotsan reload'


function dotsan {
    case $1 in
        reload)
            source ${HOME}/.bashrc
        ;;
        code)
            code ${__dotsan__home}
        ;;
        cd)
            pushd ${__dotsan__home}
        ;;
        update)
            pushd ${__dotsan__home} > /dev/null
            git pull
            if [ -e 'private' ]; then
                pushd private > /dev/null
                git pull
                popd > /dev/null
            fi
            bash setup.sh
            popd > /dev/null
        ;;
        version)
            pushd ${__dotsan__home} > /dev/null
            # shamelessly stolen from https://stackoverflow.com/a/3278427/625802
            git remote update
            UPSTREAM=${2:-'@{u}'}
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse "$UPSTREAM")
            BASE=$(git merge-base @ "$UPSTREAM")

            R=$'\e[31m'
            G=$'\e[32m'
            Y=$'\e[33m'
            B=$'\e[34m'
            RE=$'\e[0m'

            if [ $LOCAL = $REMOTE ]; then
                echo "local  $B$LOCAL$RE"
                echo "remote $B$REMOTE$RE"
                echo "=> ${G}up to date$RE"
            elif [ $LOCAL = $BASE ]; then
                echo "local  $R$LOCAL$RE"
                echo "remote $G$REMOTE$RE"
                echo "=> ${B}pull needed"
            elif [ $REMOTE = $BASE ]; then
                echo "local  $G$LOCAL$RE"
                echo "remote $R$REMOTE$RE"
                echo "=> ${Y}push needed"
            else
                echo "local  $R$LOCAL$RE"
                echo "remote $R$REMOTE$RE"
                echo "=> ${Y}diverged$RE"
            fi
            popd > /dev/null
        ;;
        dpi)
            case $2 in
                high)
                    echo "Xft.dpi: 192" > ~/.Xresources
                    cat ~/.Xresources
                    echo "Logout for changes to take effect (Super+Shift+Q)"
                ;;
                low)
                    echo "Xft.dpi: 96" > ~/.Xresources
                    cat ~/.Xresources
                    echo "Logout for changes to take effect (Super+Shift+Q)"
                ;;
                *)
                    cat ~/.Xresources
                ;;
            esac
        ;;
        *)
            echo "Usage: dotsan [reload|diff|commit|update|version]"
            echo "       dotsan dpi [high|low]"
        ;;
    esac
}
