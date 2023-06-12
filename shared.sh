#! /usr/bin/env bash

# (static) directory that statman will use to populate outputs for reading
# allows for commands running at different intervals to populate the same term
# unforunately, I don't know of an easy way to synchronise loops in different
# processes (using bash)
export statman_readout_directory="/dev/shm/readout-statman-$UID"
# TODO: If I share this script, potentially some os might not do this
# and might require manually creating a tmpfs or ramfs

export columns="$(tput cols)"
export columns_seq=$(seq $columns)

# Helpers
function command_to_file() {
    local target_name="$1"
    local command_output="$2"

    echo "$command_output" > "$statman_readout_directory/$target_name"
}

# create empty line
function generate_empty_line() {
    local output=""
    for i in $columns_seq; do
        output="$output "
    done
    echo -ne "$output"
}

# Elements
function line() {
    local output=""

    for i in $columns_seq
    do
        output="$output$1"
    done

    echo -ne "$output"
}


export rows="$(tput lines)"
export rows_seq=$(seq $rows)
export empty_line="$(line ' ')"

# less aggressive clear, fill terminal buffer with whitespace
function wipe_screen() {
    # send cursor to home
    tput cup 0 0

    for i in $rows_seq; do
        echo -ne "$empty_line"
    done

    # send cursor to home (again)
    tput cup 0 0
}

function bar() {
    local width="$1"
    local percent_decimal="$2"

    # How many elements to render
    local fill_width=$(echo "scale=0; ($percent_decimal * $width) / 1" | bc)

    local output="["

    for i in $(seq $width)
    do
        if (( i < fill_width )); then
            output="$output="
        elif (( i == fill_width )); then
            output="$output#"
        else
            output="$output "
        fi
    done

    echo "$output]"
}


function timekeeper_bar_render() {
    local width="$1"
    local percent_decimal="$2"

    # How many elements to render
    local fill_width=$(echo "scale=0; ($percent_decimal * $width) / 1" | bc)

    local output=""

    for i in $(seq $width)
    do
        if (( i < fill_width )); then
            output="$output·"
        elif (( i == fill_width )); then
            output="$output⏺"
        else
            output="$output·"
        fi
    done

    echo "$output"
}
