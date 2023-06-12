#! /usr/bin/env bash

# Import dependancies
current_dir="$(dirname -- "$0")"
source "$current_dir/../shared.sh"

function render_user_and_host() {
    echo "$USER@$(hostname)"
}

command_to_file "user-and-host" "$(render_user_and_host)"
