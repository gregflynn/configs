#!/usr/bin/env bash

if [[ "$1" == "" ]]; then
    feh -Tview
elif [ -d "$1" ]; then
    feh -Tview $1
else
    feh -Tview --start-at $1
fi
