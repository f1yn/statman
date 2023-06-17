#! /usr/bin/env bash

# Import dependencies
source "$statman_dir/shared.sh"

##
# Renders the current username and hostname that this statman is using
# Runs very infrequently - technically should only need to be computed once
function render_user_and_host() {
    echo "$USER@$(hostname)"
}

command_to_file "user-and-host" "$(render_user_and_host)"
