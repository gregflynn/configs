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

# ZSH Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[command]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'

# Theme
__right=$'\uE0B1'
__prompt__userpath() {
    local C0=$'\e[34m'
    local C1=$'\e[35m'
    local C2=$'\e[35m'
    local C3=$'\e[35m'
    local me=''

    # check for superuser
    if [[ "$USER" == "root" ]] || [[ "$DS_ROOT" != "" ]]; then
        C0=$'\e[31m'
        me='root'
    fi

    if [[ "$SSH_CLIENT" != "" ]] || [[ "$SSH_TTY" != "" ]] || [[ "$DS_SSH" != "" ]]; then
        C0="%{$fg[yellow]%}"
        me="$USER"
    fi

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:~:"); fi
    
    # shorten path name with perl
    # from: https://superuser.com/a/1172745
    local path=$(echo $P | perl -pe 's/(\w)[^\/]+\//\1\//g')

    if [[ "$me" != "" ]]; then
        echo -n " $C0$me $__right"
    fi

    echo -n "$C2 $path $C3$__right"
}

__prompt__git() {
    local git_status="$(git_prompt_info)"
    if [[ "$git_status" != "" ]]; then
        local C0="%{$fg[green]%}"
        echo -n " $git_status%{$reset_color%}$C0 $__right"
    fi
}

__prompt__line1() {
    C_=$'\e[0m'
    echo -n "$C_$(__prompt__userpath)$(__prompt__git)$C_"
}

__prompt__line2() {
    if [[ "$USER" == "root" ]]; then
        echo -n "%{$fg[red]%}"
    else
        echo -n "%{$fg[yellow]%}"
    fi
    echo -n $'\uf061'
}

__prompt__rc="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
__prompt__host() {
    local color='yellow'
    if [[ "$SSH_CLIENT" != "" ]] || [[ "$SSH_TTY" != "" ]]; then
        color='red'
    fi
    echo -n "%{$fg[$color]%}$(hostname)%{$reset_color%}"
}

# stolen from the avit theme
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
RPROMPT='$__prompt__rc$(__prompt__host)'
