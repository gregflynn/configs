alias reload='dotsan reload'

function dotsan () {
    case $1 in
        reload)
            source ~/.bashrc
        ;;
        diff)
            pushd $DOTINSTALL > /dev/null
            git diff --cached
            git diff
            git status
            popd > /dev/null
        ;;
        commit)
            pushd $DOTINSTALL > /dev/null
            git add --all
            git commit "${@:2}"
            popd > /dev/null
        ;;
        push)
            pushd $DOTINSTALL > /dev/null
            git push
            popd > /dev/null
        ;;
        update)
            pushd $DOTINSTALL > /dev/null
            git pull
            bash setup.sh
            # call tilix here to test the new version
            tilix
            popd > /dev/null
        ;;
        version)
            pushd > /dev/null
            git remote update
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
            case $2 in
                internal)
                    XRAND_OUT=$(xrandr | grep " connected")
                    if [[ $(cat "$XRAND_OUT" | wc -l) != 2 ]]; then
                        echo "Only 1 monitor detected"
                    else
                        # assume the first monitor is internal
                        INTERNAL=$(cat "$XRAND_OUT" | head -n 1 | awk '{ print $1; }')

                        # assume the last monitor is the
                        EXTERNAL=$(cat "$XRAND_OUT" | tail -n 1 | awk '{ print $1; }')

                        xrandr --ouput $INTERNAL --primary --output $EXTERNAL --off
                    fi
                ;;
                external)
                    XRAND_OUT=$(xrandr | grep " connected")
                    if [[ $(cat "$XRAND_OUT" | wc -l) != 2 ]]; then
                        echo "Only 1 monitor detected"
                    else
                        # assume the first monitor is internal
                        INTERNAL=$(cat "$XRAND_OUT" | head -n 1 | awk '{ print $1; }')

                        # assume the last monitor is the
                        EXTERNAL=$(cat "$XRAND_OUT" | tail -n 1 | awk '{ print $1; }')

                        xrandr --ouput $EXTERNAL --primary --output $INTERNAL --off
                    fi
                ;;
                *)
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
