alias reload='dotsan reload'

function dotsan () {
    case $1 in
        reload)
            source ~/.bashrc
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
            bash setup.sh
            # call tilix here to test the new version
            tilix
            popd > /dev/null
        ;;
        version)
            pushd $DOTINSTALL > /dev/null
            git remote update
            git status -uno
            popd >/dev/null
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
