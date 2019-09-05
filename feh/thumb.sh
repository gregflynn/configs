#!/usr/bin/env bash

dir="$1"

if [[ "$dir" == "" ]]; then
    dir=$(pwd)
fi

feh -Tdirthumb $dir
