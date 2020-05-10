vim() {
    if command -v nvim > /dev/null; then
        nvim $@
    else
        /usr/bin/vim $@
    fi
}

vimdiff() {
    if command -v nvim > /dev/null; then
        nvim -d $@
    else
        /usr/bin/vimdiff $@
    fi
}

