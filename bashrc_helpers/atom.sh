#! /bin/bash

function apmsync() {
    while read pkg; do
        mkdir -p ~/.atom/packages/$pkg
    done < ~/.sanity/atom/packages

    apm update

    vimdiff ~/.sanity/atom/packages <(ls ~/.atom/packages/ | sed 's/\t/\n/g' > atom/packages)
}
