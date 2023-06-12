#! /usr/bin/env bash

statman_dir="$(dirname -- "$0")"

# Force reconcile
sleep .5;

source $statman_dir/shared.sh

function render() {
    # fill entire terminal white whitespace, then reset the cursor
    # will ensure that we are rendering on a clean slate
    wipe_screen

    # Render widgets below!
    local o=$statman_readout_directory
    echo "$(cat "$o/current-time") - SESSION: $(cat "$o/user-and-host")"
    line '-'
    cat "$o/timekeeper"
    cat "$o/networking"
    cat "$o/memory-usage"
    cat "$o/volume"
    # advanced audio
    cat "$o/now-playing"
    line '-'
    cat "$o/pending-updates"
    line '-'
}

# when the direct rendering mode is enabled, make sure we call the
# function immediately
if [[ ! -z "${STATMAN_EXEC_RENDER}" ]]; then
    render
fi
