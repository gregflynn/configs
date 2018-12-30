#! /bin/bash


# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


__dotsan__home="$HOME/.sanity"
__bash__home="$__dotsan__home/bash"
export HISTCONTROL=ignoreboth
export HISTSIZE=5000


#
# Fix for VTE terminals
#
if [[ ${VTE_VERSION} ]]; then
    if [[ -e /etc/profile.d/vte.sh ]]; then
        # Arch
        source /etc/profile.d/vte.sh
    fi
fi

function __bash__import {
    rel_path="$1.sh"
    full_path="$__bash__home/$rel_path"
    source ${full_path}
    if [[ "$?" != "0" ]]; then
        __dsc__error "Failed to import $rel_path"
        return 1
    fi
}

__bash__import colors
__bash__import aliases
__bash__import dock
__bash__import dotsan
__bash__import prompt
__bash__import sys
__bash__import pac/pac


source /usr/share/git/completion/git-completion.bash

if [[ -e "$HOME/.pyenv" ]]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    eval "$(pyenv init -)"
    if [[ -e "$HOME/.pyenv/plugins/pyenv-virtualenv" ]]; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
    source /usr/share/nvm/init-nvm.sh
fi

if [[ -e "$__dotsan__home/private/bashrc.sh" ]]; then
    source ${__dotsan__home}/private/bashrc.sh
fi

stty -ixon
