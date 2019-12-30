__right=""


if [[ "$ZSH_VERSION" == "" ]]; then
    _RED=$'\e[31m'
    _GREEN=$'\e[32m'
    _YELLOW=$'\e[33m'
    _BLUE=$'\e[34m'
    _PURPLE=$'\e[35m'
    _ORANGE=$'\e[36m'
    _WHITE=$'\e[37m'
else
    _RED="%{$fg[red]%}"
    _GREEN="%{$fg[green]%}"
    _YELLOW="%{$fg[yellow]%}"
    _BLUE="%{$fg[blue]%}"
    _PURPLE="%{$fg[magenta]%}"
    _ORANGE="%{$fg[cyan]%}"
    _WHITE="%{$fg[white]%}"
fi

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
    local user_color="$_BLUE"
    local me="$USER"

    # check for superuser
    if _is_root; then
        user_color="$_RED"
        me='root'
    fi

    if [[ "$me" != "" ]]; then
        echo -n " $user_color$me "
    fi

    # print host on ssh
    if _is_ssh; then
        echo -n "$_YELLOW$__right $(hostname) "
    fi

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:~:"); fi

    # shorten path name with perl
    # from: https://superuser.com/a/1172745
    local path=$(echo $P | perl -pe 's/(\w)[^\/]+\//\1\//g')

    echo -n "$_PURPLE$__right $path "
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
    if [ "$staged" = "1" ]; then statuses="$statuses ${_GREEN}"; fi
    if [ "$conflicted" = "1" ]; then statuses="$statuses ${_RED}"; fi
    if [ "$changes" = "1" ]; then statuses="$statuses ${_RED}~"; fi
    if [ "$untracked" = "1" ]; then statuses="$statuses ${_RED}"; fi

    # handle stashes
    if ! test -z "$(git stash list 2>/dev/null)"; then
        statuses="$statuses ${_PURPLE}"
    fi

    branch=$(echo "${branch/\#\# }" | cut -f1 -d"^")

    # add a happy little checkmark
    if [[ "$statuses" == "" ]] && [[ "$branch" != "" ]]; then
        statuses=" ${_GREEN}"
    fi
    echo -n "$branch$statuses"
}

_prompt_git() {
    local git_status="$(_git_prompt_info)"
    if [[ "$git_status" != "" ]]; then
        echo -n "$_ORANGE$__right $git_status "
    fi
}

_prompt_venv() {
    local venv_name=$(pyenv local 2>/dev/null)
    if [[ "$venv_name" == "" ]]; then
        # try the env var
        venv_name="$VIRTUAL_ENV"
    fi
    if [[ "$venv_name" != "" ]]; then
        echo -n "$_GREEN$__right py:$venv_name"
    fi
}

_prompt_carrot() {
    local color="$_YELLOW"
    if _is_root; then
        color="$_RED"
    fi
    case "$KEYMAP" in
        vicmd)
            color="$_BLUE"
        ;;
    esac
    echo -n "$color$__right$__right$__right"
}

_prompt_host() {
    if _is_ssh; then
        echo -n "$_YELLOW$(hostname) "
    fi
}

if [[ $(tty) == /dev/pts/* ]]; then
    if [[ "$ZSH_VERSION" == "" ]]; then
        ME="$(whoami)"

        # resets the color _after_ the user input
        normalcol="$(tput sgr0)"
        trap 'echo -n "$normalcol"' DEBUG

        if [ "$ME" == "root" ]; then
            prompt_color=$'\e[31m'
        else
            prompt_color=$'\e[33m'
        fi

        PS1=$'
$(_prompt_userpath)$(_prompt_git)$(_prompt_venv)

\[$prompt_color\]bash $__right$__right$__right '
    else
        PROMPT='
%{$reset_color%}$(_prompt_userpath)$(_prompt_git)$(_prompt_venv)%{$reset_color%}

$(_prompt_carrot) '
    fi
fi
