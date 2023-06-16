#! /usr/bin/env bash

# Import dependancies
source "$statman_dir/shared.sh"

function render_user_and_host() {
    echo "$USER@$(hostname)"
}

command_to_file "user-and-host" "$(render_user_and_host)"
