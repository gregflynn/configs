#!/usr/bin/env bash


function __dotsan__color__mapper {
    case $1 in
        black) echo '0' ;;
        red) echo '1' ;;
        green) echo '2' ;;
        yellow) echo '3' ;;
        blue) echo '4' ;;
        purple) echo '5' ;;
        aqua) echo '6' ;;
        white) ;&
        *) echo '7' ;;
    esac
}

function __dotsan__color__variation__mapper {
    case $1 in
        bold) echo '1' ;;
        dim) echo '2' ;;
        underline) echo '3' ;;
        blink) echo '4' ;;
        invert) echo '5' ;;
        normal) ;&
        *) echo '0' ;;
    esac
}

function __dotsan__color {
    color='\e['

    if [[ "$3" != "" && "$3" != 'pass' ]]; then
        variant=$(__dotsan__color__variation__mapper $3)
    fi

    if [[ "$1" != "" && "$1" != 'pass' ]]; then
        fg_color=$(__dotsan__color__mapper $1)

        if [ "$variant" != "" ]; then
            color="${color};3${fg_color}"
        else
            color="${color}3${fg_color}"
        fi
    fi

    if [[ "$2" != "" && "$2" != 'pass' ]]; then
        bg_color=$(__dotsan__color__mapper $2)

        if [[ "$variant" != "" || "$fg_color" != "" ]]; then
            color="${color};4${bg_color}"
        else
            color="${color}4${bg_color}"
        fi
    fi

    echo "${color}m"
}

function __dotsan__color__reset {
    echo -e '\e[0m'
}

function __dotsan__echo {
    echo -e "$(__dotsan__color $2 $3 $4)${1}$(__dotsan__color__reset)"
}

function __dotsan__warn {
    __dotsan__echo "[WARN] $1" 'yellow'
}

function __dotsan__error {
    __dotsan__echo "[ERROR] $1" 'red'
}

function __dotsan__info {
    __dotsan__echo "$1" 'blue'
}

function __dotsan__success {
    __dotsan__echo "$1" 'green'
}
