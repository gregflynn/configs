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
        install)
            pushd ${__dotsan__home} > /dev/null
            bash setup.sh "${@:2}"
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
        init)
            modname="$2"
            if [ "$modname" == "" ]; then
                __dsc__error "No module name specified"
                return 1
            fi

            if [[ $modname =~ ^[a-zA-Z_]+$ ]]; then
                if [ -d $__dotsan__home/$modname ]; then
                    __dsc__error "Module '$modname' already exists"
                    return 1
                fi

                echo "Creating module $modname"
                mkdir $__dotsan__home/$2
                cat ${__dotsan__home}/module_init.sh | sed "s;MODULE;$modname;g" > $__dotsan__home/$modname/init.sh
            else
                __dsc__error "Invalid module name '$modname'"
            fi
        ;;
        inject)
            host="$2"
            if [[ "$host" == "" ]]; then
                __dsc__error "No host given"
                return 1
            fi

            ssh ${host} "git clone https://github.com/gregflynn/dotsanity.git ~/.sanity"
            ssh ${host} "bash ~/.sanity/setup.sh"
            ssh ${host}
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
        watch)
            module="$2"

            if [[ "$module" == "" ]]; then
                __dsc__error "Must specify a module to watch"
                return 1
            fi

            while true; do
                dotsan install ${module}
                sleep 2
            done
        ;;
        *)
            echo "Usage: dotsan [reload|diff|commit|update|version]"
            echo "       dotsan dpi [high|low]"
        ;;
    esac
}
