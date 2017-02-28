#! /bin/bash

RI=$'\uE0B0'
RI_LN=$'\uE0B1'

function pss_git() {
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


  # handle stashes
  STASH=$(git stash list 2>/dev/null)
  if ! test -z "$STASH"; then
    C1=$'\e[41m'
    C2=$'\e[37m'
    C3=$'\e[31m'
    echo -n "$C1$RI${C2} s $C3"
  fi

  E=""
  if [ "$staged" = "1" ]; then E="$E +"; fi

  C=$'\e[31m'
  E="$E$C"

  if [ "$conflicted" = "1" ]; then E="$E M"; fi
  if [ "$changes" = "1" ]; then E="$E *"; fi
  if [ "$untracked" = "1" ]; then E="$E u"; fi

  IFS="^" read -ra branch_fields <<< "${branch/\#\# }"
  branch="${branch_fields[0]}"

  C1=$'\e[40m'
  C2=$'\e[32m'
  C3=$'\e[30m'
  echo -n "$C1$RI$C2 $branch$E $C3"
}

function pss_user() {
  C1=$'\e[45m'
  C2=$'\e[3;37m'
  C3=$'\e[0;35m'
  ME=`whoami`
  if [[ $USER_SKIP_RI -gt 0 ]]; then
    RI=""
  fi
  echo -n "$C1$RI$C2 $ME $C3"
}

function pss_host() {
  C1=$'\e[44m'
  C2=$'\e[3;37m'
  C3=$'\e[34m'
  H=`hostname`
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    C1=$'\e[43m'
    C2=$'\e[3;30m'
    C3=$'\e[33m'
  fi
  echo -n "$C1$RI$C2 $H $C3"
}

function pss_pwd() {
  C0=$'\e[40m'
  C1=$'\e[0;30;46m'
  C2=$'\e[37m'
  C3=$'\e[36m'
  _R=$'\e[30m'
  if [[ ":$PWD" == ":$HOME"* ]]; then
    # P=`pwd | sed "s:$HOME:~:g"  | sed "s/\// $_R$RI_LN$C2 /g"`
    P=`pwd | sed "s:$HOME:~:g"`
  else
    # P=`pwd | cut -c 2- | sed "s/\// $RI_LN /g"`
    P=`pwd`
  fi
  echo -n "$C0$RI$C1$RI$C2 $P $C3"
}

function pss_venv() {
  C1=$'\e[42m'
  C2=$'\e[30m'
  C3=$'\e[32m'
  if ! test -z $VIRTUAL_ENV; then
    echo -n "$C1$RI$C2 py $C3"
  fi
}

function pss_ps1() {
  USER_SKIP_RI=1
  C0=$'\e[30m'
  CE=$'\e[49m'
  C_=$'\e[0m'
  echo -n "$C0$(pss_user)$(pss_host)$(pss_pwd)$(pss_venv)$(pss_git)$CE$RI$C_"
}

PS1=$'$(pss_ps1)
\[\e[35m\]$RI_LN\[\e[0m\] '
