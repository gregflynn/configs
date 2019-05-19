#!/usr/bin/env bash

__dsc__mapper() {
    case $1 in
        black)  echo '0' ;;
        red)    echo '1' ;;
        green)  echo '2' ;;
        yellow) echo '3' ;;
        blue)   echo '4' ;;
        purple) echo '5' ;;
        cyan)   echo '6' ;;
        *)      echo '7' ;;
    esac
}


__dsc__variation__mapper() {
    case $1 in
        bold|b) echo '1' ;;
        dim|d) echo '2' ;;
        italic|i) echo '3' ;;
        underline|u) echo '4' ;;
        invert|inv) echo '7' ;;
        *) echo '0' ;;
    esac
}


__dsc() {
    local fg="$1"
    local bg="$2"
    local var="$3"
    local no_escape="$4"

    local color='\e['

    if [[ "$no_escape" != "" ]]; then
        color="["
    fi

    if [[ "$var" != "" && "$var" != 'p' ]]; then
        variant=$(__dsc__variation__mapper $3)
        color="${color}${variant}"
    fi

    if [[ "$fg" != "" && "$fg" != 'p' ]]; then
        fg_color=$(__dsc__mapper $1)

        if [[ "$variant" != "" ]]; then
            color="${color};3${fg_color}"
        else
            color="${color}3${fg_color}"
        fi
    fi

    if [[ "$bg" != "" && "$bg" != 'p' ]]; then
        bg_color=$(__dsc__mapper $2)

        if [[ "$variant" != "" || "$fg_color" != "" ]]; then
            color="${color};4${bg_color}"
        else
            color="${color}4${bg_color}"
        fi
    fi

    echo "${color}m"
}


__dsc__reset() {
    echo -e '\e[0m'
}


__dsc__echo() {
    local txt="$1"
    local fg="$2"
    local bg="$3"
    local variant="$4"
    local no_newline="$5"

    local echo_string="$(__dsc ${fg} ${bg} ${variant})${txt}$(__dsc__reset)"

    if [[ ${no_newline} == "" ]]; then
        echo -e ${echo_string}
    else
        echo -e -n ${echo_string}
    fi
}


__dsc__ncho() {
    # like __dsc__echo but without trailing newline
    __dsc__echo "${1:-p}" "${2:-p}" "${3:-p}" "${4:-p}" 1
}


__dsc__line() {
    # echo a line of strings with different foreground colors
    # $1...$N where $N % 2 == 0
    #       (text, foreground color) pairs of 2 arguments
    local loaded=false
    local text=""

    for arg in "$@"; do
        if [[ "$text" == "" ]]; then
            text="$arg"
        else
            __dsc__ncho "$text" "$arg"
            text=""
        fi
    done
    echo # print just a newline
}


__dsc__hl() {
    # highlight a regex from stdin, in a certain color
    # STDIN the text to highlight
    # $1 regex to match (sed style)
    # $2 the foreground color
    # $3 the background color
    # $4 the variant

    # https://unix.stackexchange.com/a/45954/212439
    local esc=$(printf '\033')
    local color=$(__dsc ${2:-p} ${3:-p} ${4:-p} 1)
    sed "s/$1/$esc$color&$esc[0m/g"
}


__dsc__warn() {
    # print a colored warning message to the console
    # $1 message
    __dsc__echo "[WARN] $1" yellow
}

__dsc__error() {
    # print a colored error message to the console
    # $1 message
    __dsc__echo "[ERROR] $1" red
}

__dsc__info() {
    __dsc__echo "$1" blue
}

__dsc__success() {
    __dsc__echo "$1" green
}

colors() {
    for x in {0..8}; do
        for i in {30..37}; do
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo
}

gradient() {
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s s s s s s s s s s s s s s s s;
        for (colnum = 0; colnum<256; colnum++) {
            r = 255-(colnum*255/255);
            g = (colnum*510/255);
            b = (colnum*255/255);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}
