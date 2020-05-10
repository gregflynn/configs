#!/usr/bin/env bash

picom --config '{DS_HOME}/modules/x11/picom.conf' -b

/usr/bin/start-pulseaudio-x11

xautolock -notify 60 -detectsleep -time 15 -locker "bash {DS_LOCK}" &

export WINIT_HIDPI_FACTOR=1
export WINIT_X11_SCALE_FACTOR=1

if command -v xmodmap > /dev/null; then
    xmodmap_loc='{DS_HOME}/modules/x11/xmodmap'
    if [[ -f ${xmodmap_loc} ]]; then
        xmodmap ${xmodmap_loc}
    fi
fi

# HACK for autostarting libinput-gestures
if [[ -e "$HOME/.config/libinput-gestures.conf" ]]; then
    libinput-gestures-setup start
fi

# start thunar in daemon mode
if command -v thunar > /dev/null; then
    thunar --daemon &
fi
