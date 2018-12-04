#!/usr/bin/env bash


__dotsan__hex__background='272822'
__dotsan__hex__black='000000'
__dotsan__hex__blue='66D9EF'
__dotsan__hex__cyan='A1EFE4'
__dotsan__hex__green='A6E22E'
__dotsan__hex__gray='75715E'
__dotsan__hex__orange='FD971F'
__dotsan__hex__purple='AE81FF'
__dotsan__hex__red='F92672'
__dotsan__hex__white='F8F8F2'
__dotsan__hex__yellow='F4BF75'
__dotsan__hex__yellow__text='E6DB74'


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
    local fg="$1"
    local bg="$2"
    local var="$3"
    color='\e['

    if [[ "$var" != "" && "$var" != 'p' ]]; then
        variant=$(__dotsan__color__variation__mapper $3)
    fi

    if [[ "$fg" != "" && "$fg" != 'p' ]]; then
        fg_color=$(__dotsan__color__mapper $1)

        if [[ "$variant" != "" ]]; then
            color="${color};3${fg_color}"
        else
            color="${color}3${fg_color}"
        fi
    fi

    if [[ "$bg" != "" && "$bg" != 'p' ]]; then
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
    local txt="$1"
    local fg="$2"
    local bg="$3"
    local variant="$4"
    local no_newline="$5"

    local echo_string="$(__dotsan__color ${fg} ${bg} ${variant})${txt}$(__dotsan__color__reset)"

    if [[ ${no_newline} == "" ]]; then
        echo -e ${echo_string}
    else
        echo -e -n ${echo_string}
    fi
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
