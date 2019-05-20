zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '{HOME}/.zshrc'

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

source {ANTIGEN_INSTALL}
antigen use oh-my-zsh
antigen bundle git
antigen bundle colored-man-pages
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# fix home and end keys
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

alias compreinit='rm -f ~/.zcompdump; compinit'

{DS_SOURCE}
__ds__src "{DS_SOURCES}"
fpath=({DS_COMP_ZSH} $fpath)

# Theme
__right=$'\uE0BC'
__right_alt=$'\uE0C7'
__prompt__userpath() {
    C0=$'\e[34m'
    C1=$'\e[35m'
    C2=$'\e[30;45m'
    C3=$'\e[35m'

    # check for superuser
    if [[ "$ME" == "root" || "$DOTSAN_DEBUG_ROOT" == "1" ]]; then
        C0=$'\e[31m'
    fi

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:~:"); fi
    
    # shorten path name with perl
    # from: https://superuser.com/a/1172745
    local path=$(echo $P | perl -pe 's/(\w)[^\/]+\//\1\//g')

    echo -n " $C0$USER $C1$__right_alt$C2 $path $C3"
}

__prompt__git() {
    local git_status="$(git_prompt_info)"
    if [[ "$git_status" != "" ]]; then
        C1=$'\e[40m'
        C2=$'\e[32m'
        C3=$'\e[30m'
        echo -n "$C1$__right$C2 $git_status $C3"
    fi
}

__prompt__line1() {
    CE=$'\e[49m'
    C_=$'\e[0m'
    echo -n "$C_$(__prompt__userpath)$(__prompt__git)$CE$__right$C_"
}

__prompt__line2() {
    echo -n "%{$fg[yellow]%}"
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$DOTSAN_DEBUG_HOST" ]; then
        echo -n -e "${HOSTNAME} "
    fi
    echo $'\uf061'
}

# stolen from the avit theme
local _return_status="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$bg[black]%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

PROMPT='
$(__prompt__line1)
$(__prompt__line2) '
RPROMPT='${_return_status}'
