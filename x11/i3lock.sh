#!/usr/bin/env bash

screen="/tmp/screen.png"

# take screenshot
scrot "$screen"

# pixelate
convert "$screen" -scale 10% -scale 1000% "$screen"

i3lock \
    --ignore-empty-password \
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
    --ringcolor={DS_BLUE}FF \
    --ringvercolor={DS_YELLOW}FF \
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
    --timecolor={DS_BLUE}FF \
    --time-font="Hack" \
    --timesize=102 \
    --datestr=" " \
    ;

rm "$screen"
