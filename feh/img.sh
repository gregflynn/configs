#!/usr/bin/env bash

_base_feh="feh -Tview --title %n"

if [[ "$1" == "" ]]; then
    $_base_feh -Tview
elif [ -d "$1" ]; then
    $_base_feh -Tview $1
else
    $_base_feh -Tview --start-at $1
fi
