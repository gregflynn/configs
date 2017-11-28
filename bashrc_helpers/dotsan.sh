alias reload='dotsan reload'

function dotsan () {
    case $1 in
        reload)
            source ~/.bashrc
        ;;
        tic)
            tic -x $DOTINSTALL/termite.terminfo
        ;;
        code)
            code $DOTINSTALL
        ;;
        cd)
            pushd $DOTINSTALL
        ;;
        update)
            pushd $DOTINSTALL > /dev/null
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
            pushd $DOTINSTALL > /dev/null
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
        monitor)
            XRAND_OUT=$(xrandr | grep " connected")
            # assume the first monitor is internal
            INTERNAL=$(echo "$XRAND_OUT" | head -n 1 | awk '{ print $1; }')

            # assume the last monitor is the
            EXTERNAL=$(echo "$XRAND_OUT" | tail -n 1 | awk '{ print $1; }')
            case $2 in
                internal)
                    if [[ $(echo "$XRAND_OUT" | wc -l) != 2 ]]; then
                        echo "Only 1 monitor detected"
                    else
                        xrandr --output $INTERNAL --mode 3200x1800 --primary --output $EXTERNAL --off
                    fi
                ;;
                external)
                    XRAND_OUT=$(xrandr | grep " connected")
                    if [[ $(echo "$XRAND_OUT" | wc -l) != 2 ]]; then
                        echo "Only 1 monitor detected"
                    else
                        xrandr --output $EXTERNAL --mode 3440x1440 --primary --output $INTERNAL --off
                    fi
                ;;
                *)
                    if [[ "$INTERNAL" != "" ]]; then
                        echo "Internal display: $INTERNAL"
                    fi
                    if [[ "$EXTERNAL" != "" ]]; then
                        echo "External display: $EXTERNAL"
                    fi
                    echo "Usage: dotsan monitor [internal|external]"
                ;;

            esac
        ;;
        *)
            echo "Usage: dotsan [reload|diff|commit|update|version]"
            echo "       dotsan dpi [high|low]"
        ;;
    esac
}
