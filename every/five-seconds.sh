#! /usr/bin/env bash

# Import dependancies
source "$statman_dir/shared.sh"

function render_cpu_usage() {
    local all_cpu_stats="$(mpstat -P ALL 2 1 | grep Average | tail -n +2)"

    separator
    echo "${co_label}CPU:$(cor)"

    # bar width = termsile - label left - label right - bar pad
    local bar_width=$(echo "scale=0; ($columns / 2) - 2 - 4 - 4" | bc)

    # loop through each of the lines from mpstat (just the averages)
    while IFS= read -r line; do
        # get the cpu id from the command output
        local cpu_id="$(echo -n "$line" | awk '{print $2}')"
        
        # Alias all as '*'
        if [[ $cpu_id == "all" ]]; then
            cpu_id='*'
        fi
        
        local cpu_idle_raw="$(echo -n "$line" | awk '{print $12}')"
        # Get the display percentage (100 - idle%)
        local cpu_percent=$(echo "scale=2; 100 - $cpu_idle_raw" | bc)
        # Get the decimal value of the pecentage
        local cpu_decimal=$(echo "scale=2; $cpu_percent / 100" | bc)
        local cpu_decimal_display=$(echo "scale=0; $cpu_percent / 1" | bc)

        printf "%+2s %s " "$cpu_id" "$(bar $bar_width $cpu_decimal)";
        echo -n "$co_fade"
        printf "%-4s" "${cpu_decimal_display}%"
        cor
    done <<< "$all_cpu_stats"
}


command_to_file "cpu-usage" "$(render_cpu_usage)"