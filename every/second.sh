#! /usr/bin/env bash

# Import dependancies
current_dir="$(dirname -- "$0")"
source "$current_dir/../shared.sh"

function render_time() {
    printf "TIME: %(%H:%M)T\n"
}

function render_timekeeper() {
    local timekeeper_file="$statman_readout_directory/timekeeper"
    local last_timekeeper_index="$(cat $timekeeper_file | head -n 1 | awk '{print $2}')"
    local last_index="${last_timekeeper_index:-0}"
    
    # set index dynamically
    let 'index=last_index +1'
    if (( $last_index >= 300 )); then
        let 'index=1'
    fi

    # calculate percentages (backwards)
    local five_minutes_percent=$(echo "scale=4; 1 - ($index / 300)" | bc)

    # other percentages have factors (scale=0 does a floor)
    # factor reprents the subset of the max duration that a different time scale uses
    # a factor is also floored, so we need to offset the factor by 1 so we can easily multiply it later
    local minute_factor=$(echo "scale=0; ($index / 60)" | bc)
    local minute_count=$(echo "scale=0; $index - $minute_factor * 60" | bc)
    local minute_percent=$(echo "scale=4; 1 - ($minute_count / 60)" | bc)

    local half_minute_factor=$(echo "scale=0; ($index / 30)" | bc)
    local half_minute_count=$(echo "scale=0; $index - $half_minute_factor * 30" | bc)
    local half_minute_percent=$(echo "scale=34; 1 - ($half_minute_count / 30)" | bc)

    let "bar_width=columns - 2"

    echo "TIMEKEEPER:                                    $index"

    echo "|$(timekeeper_bar_render $bar_width $half_minute_percent)|"
    echo "|$(timekeeper_bar_render $bar_width $minute_percent)|"
    echo "|$(timekeeper_bar_render $bar_width $five_minutes_percent)|"
    echo "$half_second_line"
}


command_to_file "current-time" "$(render_time)"
command_to_file "timekeeper" "$(render_timekeeper)"