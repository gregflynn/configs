vim() {
    if command -v nvim > /dev/null; then
        nvim $@
    else
        vim $@
    fi
}

vimdiff() {
    if command -v nvim > /dev/null; then
        nvim -d $@
    else
        vimdiff $@
    fi
}

