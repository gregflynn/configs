#!/usr/bin/env bash


__dotsan() {
    case $1 in
        code)
            code ${__dotsan__home}
        ;;
        cd)
            pushd ${__dotsan__home}
        ;;
        update)
            pushd ${__dotsan__home} > /dev/null
            git pull
            if [ -e 'modules/private' ]; then
                pushd modules/private > /dev/null
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
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse @{u})
            BASE=$(git merge-base @ @{u})

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
        watch)
            module="$2"

            if [[ "$module" == "" ]]; then
                __dsc__error "Must specify a module to watch"
                return 1
            fi

            while true; do
                echo "$(date): $(dotsan install ${module})"
                sleep 2
            done
        ;;
        help|*)
            echo "Usage: dotsan [cd|code|update|version|watch|install]"
        ;;
    esac
}