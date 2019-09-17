__right=""


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
    local me="$USER"

    # check for superuser
    if _is_root; then
        user_color="%{$fg[red]%}"
        me='root'
    fi

    if [[ "$me" != "" ]]; then
        echo -n " $user_color$me %{$fg[magenta]%}$__right "
    fi

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:~:"); fi

    # shorten path name with perl
    # from: https://superuser.com/a/1172745
    local path=$(echo $P | perl -pe 's/(\w)[^\/]+\//\1\//g')

    echo -n "%{$fg[magenta]%}$path "
}

_git_prompt_info() {
    local gitstatus=`git status -s -b --porcelain 2>/dev/null`
    [[ "$?" -ne 0 ]] && return 0

    local branch=""
    local untracked=0
    local conflicted=0
    local changes=0
    local staged=0

    # shamelessly stolen from https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh#L27-L49
    while IFS='' read -r line || [[ -n "$line" ]]; do
        local gstatus=${line:0:2}
        while [[ -n $gstatus ]]; do
            case "$gstatus" in
                #two fixed character matches, loop finished
                \#\#) branch="${line/\.\.\./^}"; break ;;
                \?\?) ((untracked=1)); break ;;
                U?) ((conflicted=1)); break;;
                ?U) ((conflicted=1)); break;;
                DD) ((conflicted=1)); break;;
                AA) ((conflicted=1)); break;;
                #two character matches, first loop
                ?M) ((changes=1)) ;;
                ?D) ((changes=1)) ;;
                ?\ ) ;;
                #single character matches, second loop
                U) ((conflicted=1)) ;;
                \ ) ;;
                *) ((staged=1)) ;;
            esac
            gstatus=${gstatus:0:(${#gstatus}-1)}
        done
    done <<< "$gitstatus"

    local statuses=""
    if [ "$staged" = "1" ]; then statuses="$statuses %{$fg[green]%}+"; fi
    if [ "$conflicted" = "1" ]; then statuses="$statuses %{$fg[red]%}M"; fi
    if [ "$changes" = "1" ]; then statuses="$statuses %{$fg[red]%}*"; fi
    if [ "$untracked" = "1" ]; then statuses="$statuses %{$fg[red]%}u"; fi

    # handle stashes
    if ! test -z "$(git stash list 2>/dev/null)"; then statuses="$statuses %{$fg[magenta]%}s"; fi
    branch=$(echo "${branch/\#\# }" | cut -f1 -d"^")
    echo -n "$branch$statuses"
}

_prompt_git() {
    local git_status="$(_git_prompt_info)"
    if [[ "$git_status" != "" ]]; then
        echo -n "%{$fg[cyan]%}$__right $git_status%{$reset_color%} "
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
    echo -n "$__right$__right$__right"
}

_prompt_rc="%{$fg_bold[red]%}%(?..⍉)%{$reset_color%}"
_prompt_host() {
    if _is_ssh; then
        echo -n "%{$fg[yellow]%}$(hostname)%{$reset_color%} "
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

$(_prompt_host)$(_prompt_carrot) '
