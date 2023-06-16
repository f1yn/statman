#! /usr/bin/env bash

set -e

# This should be available in all scripts
export statman_dir="$(dirname -- "$0")"

echo "STARTING STATMAN"

# Include helpers and shared values
source $statman_dir/shared.sh

# Include runtime functions
source $statman_dir/runtimes.sh

# Include primary render function (if not in exec mode)
if [[ -z "${STATMAN_EXEC_RENDER}" ]]; then
    source $statman_dir/render.sh
else
    echo "-> Execution mode detection, do not forget to disable when done"
fi

# START INIT

# Ensure that subprocesses exit as expected
trap "trap - SIGTERM && kill -- -$$" INT TERM EXIT

echo "-> Initiating memstore"

# create mem store directory if it does not exist already
mkdir -p "$statman_readout_directory" || true

echo "-> Launching subroutines"

# boot each subshell process
statman_every_half_second &
statman_every_second &
statman_every_two_seconds &
statman_every_minute &
statman_every_five_minutes &

echo "-> Initiating primary render loop"

# hide cursor
printf '\e[?25l'
sleep 1
echo "-> Ready for stats"

# Render loop executes below - to change the output, go to render.sh
if [[ ! -z "${STATMAN_EXEC_RENDER}" ]]; then
    # exec renderer mode (best for testing)
    while true; do
        # minimum wait time for each render iteration
        sleep .25 &
        output="$(sh $statman_dir/render.sh)"
        # set cursor to start
        echo "$output"
        # waits for the sleep (ensuring min duration)
        wait $!
    done
else
    # direct renderer mode (best for live)
    while true; do
        # minimum wait time for each render iteration
        sleep .25 &
        # set cursor to front
        echo "$(render)"
        # waits for the sleep (ensuring min duration)
        wait $!
    done
fi
