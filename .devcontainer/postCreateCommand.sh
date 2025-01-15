#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/funcs.sh"

azd config set alpha.deployment.stacks on

grep saveenv "$HOME/.bashrc" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then

    cat <<EOT >> "$HOME/.bashrc"

DEV_ENV_FILE="\$HOME/.dev-environment"

# auto load
if [[ -f "\$DEV_ENV_FILE" ]]; then
    source "\$DEV_ENV_FILE"
fi

EOT

    declare -f saveenv clearenv >> "$HOME/.bashrc"

fi
