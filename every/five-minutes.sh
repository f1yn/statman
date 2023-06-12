#! /usr/bin/env bash

# Import dependancies
current_dir="$(dirname -- "$0")"
source "$current_dir/../shared.sh"

function render_user_and_host() {
    echo "$USER@$(hostname)"
}

function system_info() {
    echo "Local IPs: $(hostname -I)"
}

command_to_file "user-and-host" "$(render_user_and_host)"
command_to_file "system-info" "$(system_info)"