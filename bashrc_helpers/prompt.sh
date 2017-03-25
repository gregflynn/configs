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

function pss_userhost() {
  C1=$'\e[37;44m'
  C2=$''
  C3=$'\e[37m'
  C4=$'\e[0;34m'
  H=`hostname`
  ME=`whoami`

  # check for ssh session
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    C2=$'\e[33m'
  fi

  # check for superuser
  if [ "$ME" == "root" ]; then
    C3=$'\e[31m'
  fi

  echo -n "$C1$C2 $H $RI_LN $C1$C3$ME $C4"
}

function pss_pwd() {
  C0=$'\e[40m'
  C1=$'\e[0;30;46m'
  C2=$'\e[37m'
  C3=$'\e[36m'
  _R=$'\e[30m'

  if [[ `whoami` == "root" ]]; then
    C0=$'\e[41m'
    C1=$'\e[0;31;46m'
  fi

  if [[ ":$PWD" == ":$HOME"* ]]; then
    P=`pwd | sed "s:$HOME:/~:"`
  else
    P=`pwd`
  fi

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

  echo -n "$C0$RI$C1$RI$C2 $SP $C3"
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
  CE=$'\e[49m'
  C_=$'\e[0m'
  echo -n "$C0$(pss_userhost)$(pss_pwd)$(pss_venv)$(pss_git)$CE$RI$C_"
}

if [ `whoami` == "root" ]; then
  C0=$'\e[31m'
else
  C0=$'\e[37m'
fi

PS1=$'$(pss_ps1)
\[$C0\]$RI_LN\[\e[0m\] '
