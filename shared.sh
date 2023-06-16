#! /usr/bin/env bash

##
# {directory} - Static detectory that statman will populate outputs and renders.
export statman_readout_directory="/dev/shm/readout-statman-$UID"

###
### TOP LEVEL HELPERS AND STATIC VALUES
###

# Functions and values that are dependancices of other commands
export columns="$(tput cols)"
export columns_seq=$(seq $columns)
export rows="$(tput lines)"
export rows_seq=$(seq $rows)

##
# Renders a line across the width of the terminal.
# This is a passthrough method, if you pass two characters, it will render two lines (e.c.t)
# $1 {char} - The character to render 
function line() {
    local output=""
    for i in $columns_seq; do
        output="$output$1"
    done
    echo -ne "$output"
}

##
# {string} - Cached value representing an empty line
export empty_line="$(line ' ')"

###
### COLOR HELPERS AND STATIC VALUES
###

export color_default=${STATMAN_DEFAULT_COLOR:-7}

##
# Renders a color code to the temrinal using the generic helper
# Unlike base tput: this command will detect when colorized output is disabled
# $1: code  The terminal color code to use (uses 64 based setaf functionality)
function co() {
    # When color rendering id disabled, don't use color 
    # See: https://no-color.org/
    if [[ -z "$NO_COLOR" ]]; then
        local code="$1"
        tput setaf "$code"
    fi
}

##
# Renders terminal to the default color code (if colors are enabled)
function cor() {
    co $color_default
}

# Color code for labels
export co_label="$(co 11)"
# Color code for empahsis
export co_emphasis="$(co 50)"
# Color codes for faded text
export co_fade="$(co 60)"


###
### WINDOW RENDERING HELPERS
###

function wipe_screen() {
    # send cursor to home
    tput cup 0 0

    for i in $rows_seq; do
        echo -ne "$empty_line"
    done

    # send cursor to home (again)
    tput cup 0 0
}

function separator() {
    echo "${co_fade}$(line '-')"
    cor
}

##
# Renders a progress-bar element to the specified width, based on the percentage provided
# $1:width {number} - The width of the bar contents (not including boundaries)
# $2:width {float} - The decimal percentage to render the bar (not including boundaries)
function bar() {
    local width="$1"
    local percent_decimal="$2"

    # How many elements to render
    local fill_width=$(echo "scale=0; ($percent_decimal * $width) / 1" | bc)

    local output="["

    for i in $(seq $width); do
        if (( i < fill_width )); then
            output="$output$co_fade=$(cor)"
        elif (( i == fill_width )); then
            output="$output#"
        else
            output="$output "
        fi
    done

    echo "$output]"
}

##
# Helper function that takes the output of a command set and writes them to the statman shared store
# $1:target_name {string} - The name of the statman memstore file to populate. This is the identifier
# $2:command_output {string} - The result of a specified rendering function (i.e the volume display function)
function command_to_file() {
    local target_name="$1"
    local command_output="$2"
    echo "$command_output" > "$statman_readout_directory/$target_name"
}