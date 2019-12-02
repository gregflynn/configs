#! /bin/bash

badge() {
    echo -n "#[fg=$2,bg=$3] $1 #[fg=$3,bg=default]"
}

__python__status() {
    local b=$(badge '' 0 2)
    local venv_name=$(pyenv version-name)
    if [[ "$venv_name" != "system" ]]; then
        if [[ "$venv_name" == "" ]]; then
            echo -n "$b #[fg=1]N/A "
        else
            local prefix=$(pyenv prefix)
            local py_version=$($prefix/bin/python --version 2>&1 | cut -f 2 -d " ")
            echo -n "$b #[fg=2]$venv_name/$py_version "
        fi
    fi
}

__docker__status() {
    local num_containers=$(docker ps --quiet | wc -l)
    if [[ "$num_containers" != "0" ]]; then
        echo -n "$(badge '🐳' 0 4) $num_containers "
    fi
}

__kube__status() {
    if command -v kubectl > /dev/null; then
        local context=$(kubectl config current-context)
        local namespace=$(kubectl config view --minify | grep namespace | awk '{ print $2 }')
        if [[ "$namespace" == "" ]]; then
            echo -n "$(badge 'k' 0 4) $context "
        else
            echo -n "$(badge 'k' 0 4) $context ($namespace) "
        fi
    fi
}

main() {
    local dir="$1"
    local badges="${@:2}"

    pushd ${dir} > /dev/null
    for badge in ${badges}; do
        case ${badge} in
            docker) __docker__status ;;
            kube) __kube__status ;;
            python) __python__status ;;
        esac
    done
    popd > /dev/null
}
main $@
