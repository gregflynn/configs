vim() {
    if command -v nvim > /dev/null; then
        nvim $@
    else
        vim $@
    fi
}
