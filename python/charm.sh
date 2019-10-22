#!/usr/bin/env bash

# Apparently JetBrains does not know how to write a CLI launcher...
_charm_launcher() {
    local install_root="$HOME/.local/share/JetBrains/Toolbox/apps/PyCharm-P/ch-0"
    local version=$(ls $install_root | grep -v plugins | grep -v vmoptions | tail -n 1)
    echo "$install_root/$version/bin/pycharm.sh $@"
    $install_root/$version/bin/pycharm.sh $@
}

_charm_launcher $@
