#!/usr/bin/env bash

compton -b -c

xautolock -time 15 -locker "bash {DS_HOME}/x11/i3lock.sh" &

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
    if [ -f '{DS_HOME}/x11/xmodmap' ]; then
        xmodmap '{DS_HOME}/x11/xmodmap'
    fi
fi

