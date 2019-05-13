#!/usr/bin/env bash


if [[ "$@" == "" ]]; then
    python3 -m _src
else
    python3 -m _src --module $@
fi
