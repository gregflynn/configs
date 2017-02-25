# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

#
# Fix for terminix sessions, because terminix is dope
#
if [[ $TERMINIX_ID ]]; then
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
  SYSTEM_PATH="~/.sanity/bashrc_helpers/$1.sh"
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

#
# pyenv
#
if which pyenv 1>/dev/null 2>/dev/null; then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if [ -e "private/bashrc" ]; then
  source private/bashrc
fi
