#! /bin/bash

RI=$'\uE0B0'
RI_LN=$'\uE0B1'
INV=$'\e[7m'

# disable default venv PS1 manipulation
export VIRTUAL_ENV_DISABLE_PROMPT=1

function thick_div {
  C1=$'\e[30m'
  R=$'\e[0m'
  P=''
  [[ "$2" != "" ]] && C1="$2"
  [[ "$1" != "" ]] && P="$1"
  echo -n "$INV$C1$RI$R$C1$P$RI"
}

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

function pss_basic() {
  C1=$'\e[44m'
  C2=$'\e[37m'
  C3=$'\e[40m'
  C4=$'\e[36m'
  C5=$'\e[0;34m'
  C6=$'\e[46m'
  C7=$'\e[37m'
  C8=$'\e[36m'
  H=`hostname`
  ME=`whoami`
  D1=$'\e[34m'
  D2=$'\e[30m'

  # check for ssh session
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    C2=$'\e[33m'
    D1="$C2"
  fi

  # check for superuser
  [[ "$ME" == "root" ]] && C4=$'\e[31m' && D2="$C4"

  # replace home dir with tilde
  if [[ ":$PWD" != ":$HOME"* ]]; then P=`pwd`
  else P=`pwd | sed "s:$HOME:/~:"`; fi

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

  echo -n "$C1$C2 $H$(thick_div $C3 $D1) $C4$ME$(thick_div $C6 $D2) $C7$SP$C8 "
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
  echo -n "$C0$(pss_basic)$(pss_venv)$(pss_git)$CE$RI$C_"
}

if [ `whoami` == "root" ]; then
  C0=$'\e[31m'
else
  C0=$'\e[37m'
fi

PS1=$'$(pss_ps1)
\[$C0\]$RI_LN\[\e[0m\] '
