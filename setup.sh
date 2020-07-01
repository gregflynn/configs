#!/usr/bin/env bash

if [[ "$DOTSAN_CONFIG_HOME" == "" ]]; then
    # default the configuration home
    DOTSAN_CONFIG_HOME="$HOME/.config/sanity"
fi
export DOTSAN_CONFIG_HOME

if ! [[ -e "$DOTSAN_CONFIG_HOME" ]]; then
    echo "Creating $DOTSAN_CONFIG_HOME"
    mkdir -p "$DOTSAN_CONFIG_HOME"
fi

if ! [[ -e "$DOTSAN_CONFIG_HOME/venv" ]]; then
    python3 -m venv "$DOTSAN_CONFIG_HOME/venv"
fi

echo "Activing venv"
. "$DOTSAN_CONFIG_HOME/venv/bin/activate"

cd "$(dirname $0)" || exit 1

echo "Installing dependencies"
pip install -q --upgrade pip
pip install -q -e .

dotsan install

deactivate
