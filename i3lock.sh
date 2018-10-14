#!/usr/bin/env bash

icon="/usr/share/icons/elementary/status/48/locked.svg"
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
    --ringcolor=66D9EFFF \
    --ringvercolor=f4bf75FF \
    --verifcolor=f4bf75FF \
    --ringwrongcolor=F92672FF \
    --wrongcolor=F92672FF \
    --insidecolor=27282200 \
    --insidevercolor=27282200 \
    --insidewrongcolor=27282200 \
    --linecolor=27282200 \
    --separatorcolor=272822FF \
    --keyhlcolor=A6E22EFF \
    --bshlcolor=F92672FF \
    --timestr="%l:%M%P" \
    --timepos="w*15/16+x:y+h*3/16" \
    --time-align 2 \
    --timecolor=66D9EFFF \
    --time-font="Hack" \
    --timesize=102 \
    --datestr=" " \
    ;

rm "$screen"
