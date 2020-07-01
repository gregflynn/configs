#! /bin/bash

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

source "{ALIASES}"
source "{PROMPT}"

if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
    source /usr/share/nvm/init-nvm.sh
fi

{DS_SOURCE}
__ds__src "{DS_SOURCES}"
__ds__src "{DS_COMP_BASH}"

stty -ixon
