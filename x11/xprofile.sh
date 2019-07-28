#!/usr/bin/env bash

compton -c -b -i 0.9 --inactive-dim 0.2

/usr/bin/start-pulseaudio-x11

xautolock -time 15 -locker "bash {DS_LOCK}" &

export WINIT_HIDPI_FACTOR=1

if command -v xmodmap > /dev/null; then
    xmodmap_loc='{DS_HOME}/x11/xmodmap'
    if [[ -f ${xmodmap_loc} ]]; then
        xmodmap ${xmodmap_loc}
    fi
fi

