#!/usr/bin/env bash

dir="$1"
thumb_size=400

if [[ "$dir" == "" ]]; then
    dir=$(pwd)
fi

feh -Tdirthumb $dir --thumb-height $thumb_size --thumb-width $thumb_size

while [[ "$?" != "0" ]]; do
    thumb_size=$(expr $thumb_size / 2)
    notify-send "Thumb image too large, trying ${thumb_size}px"
    feh -Tdirthumb $dir --thumb-height $thumb_size --thumb-width $thumb_size
done
