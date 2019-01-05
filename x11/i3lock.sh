#!/usr/bin/env bash

screen="/tmp/screen.png"

# take screenshot
scrot "$screen"

# pixelate
convert "$screen" -scale 5%  -scale 2000% "$screen"

# turn blinky off, if installed and on
blinky_status=$(/usr/bin/blinky --status 2>/dev/null)
if [[ "$blinky_status" != "" ]] && [[ "$blinky_status" != "#000000" ]]; then
    blinky --off &
fi

i3lock \
    --ignore-empty-password \
    --nofork \
    --screen=0 \
    --image="$screen" \
    --tiling \
    --indicator \
    --indpos="x+w/2:y+2*h/3" \
    --ring-width=20 \
    --radius=35 \
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
    --timepos="w*15/16+x:y+h*3/16" \
    --time-align 2 \
    --timecolor={DS_PURPLE}FF \
    --time-font="Hack" \
    --timesize=112 \
    --datestr=" " \
    ;

rm "$screen"

if [[ "$blinky_status" != "" ]] && [[ "$blinky_status" != "#000000" ]]; then
    blinky --on &
fi
