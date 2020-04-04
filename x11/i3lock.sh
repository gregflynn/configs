#!/usr/bin/env bash

mode="$1"
blinky_status=$(/usr/bin/blinky --status 2>/dev/null)

if [[ $mode == "pre" ]] || [[ $mode == "" ]]; then
    if pgrep i3lock > /dev/null; then
        exit 0
    fi

    # turn blinky off, if installed and on
    if [[ "$blinky_status" != "" ]] && [[ "$blinky_status" != "#000000" ]]; then
        blinky --off &
    fi

    nofork="--nofork"
    if [[ $mode != "" ]]; then
        nofork=""
    fi

    i3lock \
        --bar-indicator \
        --ignore-empty-password \
        --force-clock \
        --pass-media-keys \
        $nofork \
        --veriftext      "VERIFYING" \
        --wrongtext      "INCORRECT" \
        --noinputtext    "EMPTY" \
        --color          "{DS_BACKGROUND}" \
        --verifcolor     "{DS_YELLOW}FF" \
        --ringvercolor   "{DS_YELLOW}FF" \
        --ringwrongcolor "{DS_RED}FF" \
        --wrongcolor     "{DS_RED}FF" \
        --keyhlcolor     "{DS_PURPLE}FF" \
        --bar-color      "{DS_PURPLE}00" \
        --bshlcolor      "{DS_RED}FF" \
        --timestr   "%l:%M" \
        --timepos   "w*3/4:h/4" \
        --timecolor "{DS_PURPLE}FF" \
        --time-font "Roboto" \
        --time-align 0 \
        --timesize   142 \
        --datestr   "%a %m/%d" \
        --datepos   "w*3/4:h*3/8" \
        --datecolor "{DS_PURPLE}FF" \
        --date-align 0 \
        --datesize   70 \
        --bar-position "h*3/4" \
        --bar-max-height 64 \
        --bar-direction 2 \
        --bar-width 3 \
        --bar-step 4 \
        ;
fi

if [[ $mode == "post" ]] || [[ $mode == "" ]]; then
    if [[ "$blinky_status" != "" ]]; then
        blinky --on &
    fi
fi
