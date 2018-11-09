#! /bin/bash


__right=$'\uE0B0'
__right__line=$'\uE0B1'
__left=$'\uE0B2'
RI=$'\uE0B0'
RI_LN=$'\uE0B1'
INV=$'\e[7m'

# disable default venv PS1 manipulation
export VIRTUAL_ENV_DISABLE_PROMPT=1


function pss_git {
    gitstatus=`git status -s -b --porcelain 2>/dev/null`
    [[ "$?" -ne 0 ]] && return 0

    branch=""
    untracked=0
    conflicted=0
    changes=0
    staged=0

    # shamelessly stolen from https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh#L27-L49
    while IFS='' read -r line || [[ -n "$line" ]]; do
        status=${line:0:2}
        while [[ -n $status ]]; do
            case "$status" in
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
            status=${status:0:(${#status}-1)}
        done
    done <<< "$gitstatus"

    E=""
    if [ "$staged" = "1" ]; then E="$E +"; fi

    C=$'\e[31m'
    E="$E$C"

    if [ "$conflicted" = "1" ]; then E="$E M"; fi
    if [ "$changes" = "1" ]; then E="$E *"; fi
    if [ "$untracked" = "1" ]; then E="$E u"; fi

    # handle stashes
    STASH=$(git stash list 2>/dev/null)
    if ! test -z "$STASH"; then
        C1=$'\e[35m'
        E="$E$C1 s"
    fi

    IFS="^" read -ra branch_fields <<< "${branch/\#\# }"
    branch="${branch_fields[0]}"

    C1=$'\e[40m'
    C2=$'\e[32m'
    C3=$'\e[30m'
    echo -n "$C1$RI$C2 $branch$E $C3"
}

function __prompt__user {
    C1=$'\e[0;34;40m' # start of ME
    C2=$'\e[0;30m'

    # check for superuser
    if [[ "$ME" == "root" ]]; then
        C1=$'\e[31;40m'
    fi

    echo -n "$C1 $ME $C2"
}

function pss_path {
    C1=$'\e[45m'
    C2=$'\e[30m'
    C3=$'\e[35m'

    # replace home dir with tilde
    if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
    else P=$(pwd | sed "s:$HOME:/~:"); fi

    # magical path shortener, thanks ross!
    # /home/user/foo/bar =>  ~/f/bar
    # /user/share/lib => /u/s/lib
    local IFS=/ PS=${P#?} F SP=''
    for F in $PS; do
        S='/'
        [[ ${F::1} == "~" ]] && S=''
        [[ ${F::1} == "." ]] && SP="$SP$S${F::2}" && continue
        SP="$SP$S${F::1}"
    done
    if [[ ${F::1} == "." ]]; then SP="$SP${F:2}"
    else SP="$SP${F:1}"; fi

    echo -n "$C1$RI$C2 $SP $C3"
}

function pss_venv {
    C1=$'\e[42m'
    C2=$'\e[30m'
    C3=$'\e[32m'
    pyenv local > /dev/null 2>&1
    if [[ "$?" == "0" || "$VIRTUAL_ENV" != "" ]]; then
        echo -n "$C1$RI$C2 py $C3"
    fi
}

function __prompt__time {
    CURRENT=$(date +"%H:%M:%S")
    echo -e -n "\e[34m$CURRENT"
}

function __prompt__line1 {
    CE=$'\e[49m'
    C_=$'\e[0m'
    printf "%${COLUMNS}s\r%s" \
        "$(__prompt__time)" \
        "$C_$(__prompt__user)$(pss_path)$(pss_venv)$(pss_git)$CE$RI$C_"
}

function __prompt__line2 {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo -n -e "${HOSTNAME} "
    fi
    echo "${__right__line}"
}


# only set PS1 in emulated sessions
if [[ $(tty) == /dev/pts/* ]]; then
    ME="$(whoami)"
    normalcol="$(tput sgr0)"
    trap 'echo -n "$normalcol"' DEBUG

    if [ "$ME" == "root" ]; then
        prompt_color=$'\e[31m'
    else
        prompt_color=$'\e[33m'
    fi

    PS1=$'$(__prompt__line1)
\[$prompt_color\]$(__prompt__line2) '
fi
