#!/usr/bin/env bash

compton -b -c --backend glx --paint-on-overlay --vsync opengl-swc

xautolock -time 15 -locker "bash {DS_LOCK}" &

# disable gpu LED on desktop
if command -v nvidia-settings > /dev/null; then
    nvidia-settings --assign GPULogoBrightness=0
fi

# startup applications
if command -v nm-applet > /dev/null; then
    nm-applet&
fi

if command -v redshift-gtk > /dev/null; then
    redshift-gtk -l 42.4:-71&
fi

if command -v blueberry-tray > /dev/null; then
    blueberry-tray&
fi

if command -v xmodmap > /dev/null; then
    xmodmap_loc='{DS_HOME}/x11/xmodmap'
    if [ -f ${xmodmap_loc} ]; then
        xmodmap ${xmodmap_loc}
    fi
fi

