# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

DOTINSTALL="$HOME/.sanity"

#
# Fix for terminix sessions, because terminix is dope
#
if [ $TERMINIX_ID ] || [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  if [ -e /etc/profile.d/vte-2.91.sh ]; then
    # debian stretch
    source /etc/profile.d/vte-2.91.sh
  fi
  if [ -e /etc/profile.d/vte.sh ]; then
    # Arch
    source /etc/profile.d/vte.sh
  fi
fi

function sane_import() {
  # first try the local import like we're sourcing inside the repo
  LOCAL_PATH="bashrc_helpers/$1.sh"
  if [ -e "$LOCAL_PATH" ]; then
    source "$LOCAL_PATH"
    return 0
  fi

  # not in the local context, import from system
  SYSTEM_PATH="$DOTINSTALL/bashrc_helpers/$1.sh"
  if [ -e "$SYSTEM_PATH" ]; then
    source "$SYSTEM_PATH"
    return 0
  fi

  echo "ERROR: failed to import '$1'"
  return 1
}

sane_import "aliases"
sane_import "prompt"
sane_import "fabric-completion"
sane_import "git-completion"
sane_import "pacman"
sane_import "atom"

#
# pyenv
#
if [ -e "$HOME/.pyenv" ]; then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  if [ -e "$HOME/.pyenv/plugins/pyenv-virtualenv" ]; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

if [ -e "$DOTINSTALL/private/bashrc" ]; then
  source $DOTINSTALL/private/bashrc
fi

# fixes UI scaling in QT applications
export QT_AUTO_SCREEN_SCALE_FACTOR=1
