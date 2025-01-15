#!/usr/bin/env bash

azd config set alpha.deployment.stacks on

LC_ALL=C type saveenv 2>&1 | grep "is a function" > /dev/null
#if [ $? -ne 0 ]; then

    DEV_ENV_FILE="$HOME/.dev-environment"

    function loadenv() {
        if [ -f $DEV_ENV_FILE ]; then
            source $DEV_ENV_FILE
        fi
    }

    function saveenv() {
        declare -p | grep "declare --\|declare -x" |  grep -v  "declare -- PS[0-9]\|declare -- BASH_\|declare -x PATH=" > $DEV_ENV_FILE
    }

    function clearenv() {
        echo "" > $DEV_ENV_FILE
    }

    # save functions
    echo 'DEV_ENV_FILE="$HOME/.dev-environment"' >> "$HOME/.bashrc"
    declare -f loadenv saveenv clearenv >> "$HOME/.bashrc"

    # auto load
    loadenv
#fi
