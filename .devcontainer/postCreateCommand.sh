#!/usr/bin/env bash

DEV_ENV_FILE="\$HOME/.dev-environment"

cat <<EOT >> "$HOME/.bashrc"

if [[ -f "$DEV_ENV_FILE" ]]; then
    source "$DEV_ENV_FILE"
fi

saveenv() {
    # Check if var_save is set
    declare -p | grep -v "declare -[a-z]*r" > "$DEV_ENV_FILE"
}

clearenv() {
    echo "" > "$DEV_ENV_FILE"
}

EOT
