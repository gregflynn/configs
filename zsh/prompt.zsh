__right=$'\uE0B1'


_is_root() {
    if [[ "$USER" == "root" ]] || [[ "$DS_ROOT" != "" ]]; then
        return 0
    else
        return 1
    fi
}

_is_ssh() {
    if [[ "$SSH_CLIENT" != "" ]] || [[ "$SSH_TTY" != "" ]] || [[ "$DS_SSH" != "" ]]; then
        return 0
    else
        return 1
    fi
}

_prompt_userpath() {
    local user_color="%{$fg[blue]%}"
    local me=""

    # check for superuser
    if _is_root; then
        user_color="%{$fg[red]%}"
        me='root'
    fi

    if _is_ssh; then
        user_color="%{$fg[yellow]%}"
    fi

    if [[ "$me" != "" ]]; then
        echo -n "$user_color$me %{$fg[magenta]%}$__right "
    fi

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:~:"); fi

    # shorten path name with perl
    # from: https://superuser.com/a/1172745
    local path=$(echo $P | perl -pe 's/(\w)[^\/]+\//\1\//g')

    echo -n "%{$fg[magenta]%}$path "
}

_prompt_git() {
    local git_status="$(git_prompt_info)"
    if [[ "$git_status" != "" ]]; then
        echo -n "%{$fg[magenta]%}$__right $git_status%{$reset_color%} "
    fi
}

_prompt_venv() {
    local venv_name=$(pyenv local 2>/dev/null)
    if [[ "$venv_name" == "" ]]; then
        # try the env var
        venv_name="$VIRTUAL_ENV"
    fi
    if [[ "$venv_name" != "" ]]; then
        echo -n "%{$fg[green]%}$__right %{$fg[green]%}py:$venv_name"
    fi
}

_prompt_carrot() {
    if _is_root; then
        echo -n "%{$fg[red]%}"
    else
        echo -n "%{$fg[yellow]%}"
    fi
    echo -n $'\uf061'
}

_prompt_rc="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
_prompt_host() {
    local color='yellow'
    if _is_ssh; then
        color='red'
        echo -n "%{$fg[$color]%}$(hostname)%{$reset_color%}"
    fi
}

# stolen from the avit theme
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}"
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
%{$reset_color%}$(_prompt_userpath)$(_prompt_git)$(_prompt_venv)%{$reset_color%}
$(_prompt_carrot) '
RPROMPT='$_prompt_rc $(_prompt_host)'
