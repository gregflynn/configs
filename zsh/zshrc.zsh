zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '/home/greg/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin:$PATH

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="avit"
DISABLE_AUTO_UPDATE="true"

plugins=(git aws colored-man-pages emoji)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

# fix home and end keys
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

alias compreinit='rm -f ~/.zcompdump; compinit'

{DS_SOURCE}
__ds__src "{DS_SOURCES}"
fpath=({DS_COMP_ZSH} $fpath)
