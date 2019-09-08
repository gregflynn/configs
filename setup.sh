#!/usr/bin/env bash

pushd $(dirname $0) > /dev/null
if [[ "$@" == "" ]]; then
    python3 -m _src
else
    python3 -m _src --module $@
fi
popd > /dev/null
