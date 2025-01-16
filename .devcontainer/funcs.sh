#!/usr/bin/env bash

DEV_ENV_FILE="$HOME/.dev-environment"

function saveenv() {
    declare -p | grep "declare \(--\|-x\)" | grep -v "^declare \(--\|-x\) \(PS[0-9]\|BASH_.*\|PATH\|PWD\|LS_COLORS\)=" > "$DEV_ENV_FILE"
}

function clearenv() {
    rm -f "$DEV_ENV_FILE"
}

