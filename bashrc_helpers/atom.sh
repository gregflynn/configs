#! /bin/bash

function apmsync() {
    apm install --packages-file ~/.sanity/atom/packages
    vimdiff ~/.sanity/atom/packages <(ls ~/.atom/packages/ | sed 's/\t/\n/g')
}
