#!/usr/bin/env bash

mode="$1"
screen="/tmp/screen_2.png"
blinky_status=$(/usr/bin/blinky --status 2>/dev/null)

if [[ $mode == "pre" ]] || [[ $mode == "" ]]; then
    resolution=$(xdpyinfo | grep dimensions | awk '{print $2}')
    filters='noise=alls=10,scale=iw*.05:-1,scale=iw*20:-1:flags=neighbor,gblur=sigma=5'
    ffmpeg -y -loglevel 0 -s "$resolution" -f x11grab -i $DISPLAY -vframes 1 -vf "$filters" "$screen"

    # turn blinky off, if installed and on
    if [[ "$blinky_status" != "" ]] && [[ "$blinky_status" != "#000000" ]]; then
        blinky --off &
    fi

    nofork="--nofork"
    if [[ $mode != "" ]]; then
        nofork=""
    fi

    i3lock \
        --ignore-empty-password \
        $nofork \
        --screen=0 \
        --image="${screen}" \
        --tiling \
        --indicator \
        --indpos="x+w/2:y+2*h/3" \
        --ring-width=10 \
        --radius=100 \
        --noinputtext="" \
        --veriftext="" \
        --wrongtext="" \
        --force-clock \
        --ringcolor={DS_PURPLE}FF \
        --ringvercolor={DS_BLUE}FF \
        --verifcolor={DS_YELLOW}FF \
        --ringwrongcolor={DS_RED}FF \
        --wrongcolor={DS_RED}FF \
        --insidecolor={DS_BACKGROUND}00 \
        --insidevercolor={DS_BACKGROUND}00 \
        --insidewrongcolor={DS_BACKGROUND}00 \
        --linecolor={DS_BACKGROUND}00 \
        --separatorcolor={DS_BACKGROUND}FF \
        --keyhlcolor={DS_GREEN}FF \
        --bshlcolor={DS_RED}FF \
        --timestr="%l:%M%P" \
        --timepos="w/2:y+h*1/4" \
        --time-align 0 \
        --timecolor={DS_PURPLE}FF \
        --time-font="Roboto" \
        --timesize=142 \
        --datestr=" " \
        ;
fi

if [[ $mode == "post" ]] || [[ $mode == "" ]]; then
    rm "$screen"

    if [[ "$blinky_status" != "" ]]; then
        blinky --on &
    fi
fi
