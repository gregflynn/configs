#!/usr/bin/env bash


function __dotsan__tests__init {
    case $1 in
        check)
            case $2 in
                required) echo "linux" ;;
            esac
            ;;
        build)
            __dotsan__inject tests index.html

            # alternate color palette testing
            __dotsan__inject__test tests index.html test_index.html
            ;;
        install)
            ;;
    esac
}


function __dotsan__inject__test {
    module="$1"
    dist="$__dotsan__home/$module/dist"
    infile="$__dotsan__home/$module/$2"

    if [[ "$3" == "" ]]; then
        outfile="$dist/$2"
    else
        outfile="$dist/$3"
    fi

    mkdir -p ${dist}

    infile_short=$(echo ${infile} | sed "s;${HOME};~;g")
    outfile_short=$(echo ${outfile} | sed "s;${HOME};~;g")

    cat ${infile} \
        | sed "s;{DS_HOME};${__dotsan__home};g" \
        | sed "s;{DS_LOCK};${__dotsan__lock};g" \
        | sed "s;{DS_WALLPAPER};${__dotsan__wallpaper};g" \
        | sed "s;{DS_BACKGROUND};2D2A2E;g" \
        | sed "s;{DS_BLACK};727072;g" \
        | sed "s;{DS_BLUE};78DCE8;g" \
        | sed "s;{DS_CYAN};${__dotsan__hex__cyan};g" \
        | sed "s;{DS_GREEN};A9DC76;g" \
        | sed "s;{DS_GRAY};939293;g" \
        | sed "s;{DS_ORANGE};FC9867;g" \
        | sed "s;{DS_PURPLE};AB9DF2;g" \
        | sed "s;{DS_RED};FF6188;g" \
        | sed "s;{DS_WHITE};FCFCFA;g" \
        | sed "s;{DS_YELLOW};FFD866;g" \
        > ${outfile}
}
