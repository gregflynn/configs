#! /bin/bash


# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


source "{DS_HOME}/bash/prompt.sh"

if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
    source /usr/share/nvm/init-nvm.sh
fi

if [[ -e "{DS_HOME}/private/bashrc.sh" ]]; then
    source "{DS_HOME}/private/bashrc.sh"
fi

{DS_SHELL_INIT}

stty -ixon
