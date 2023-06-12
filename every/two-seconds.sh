#! /usr/bin/env bash

# Import dependancies
current_dir="$(dirname -- "$0")"
source "$current_dir/../shared.sh"

function render_memory_usage() {
    local memory_decimal=$(free | grep Mem | awk '{print $3/$2}')
    local memory=$(echo "scale=0; ($memory_decimal * 100) / 1" | bc)
    local width=$(($columns - 15))

    line '-'
    echo "MEMORY: $(bar $width $memory_decimal) $memory%"
}

function render_vm_stats() {
    # Last line is always the grep, so avoid the last line
    local all_virt_sessions="$(ps aux | grep -i qemu-system- | head -n -1)"
    local session_names="$(echo "$all_virt_sessions" | awk -F[=,] '{print $2}')"
    local session_count="$(echo "$session_names" | wc -w)"

    # TODO: Determine status for each VM by checking their CPU states and stats
    # If a process has not spiked recently, it's likely disabled
    # If it's had some activity, it's probably idle
    # Otherwise it's active

    # TODO: Add jq to read things like VFIO PCI allocations from the config that
    # gets added in the ps output. It would be nice to see what pci devices are
    # being used. This might mean we move this to a 5 second runtime though 

    line '-'
    echo "VIRTUAL MACHINES: ($session_count enabled)"

    for i in $session_names; do
        echo "- $i"
    done
}

function render_now_playing() {
    local artist="$(playerctl metadata artist 2>/dev/null)"
    local album="$(playerctl metadata album 2>/dev/null)"
    local track="$(playerctl metadata title 2>/dev/null)"

    line '-'

    if [ "$artist" == "" ]; then
        echo "MEDIA STATUS: Inactive"
        echo "MEDIA METADATA: Inactive"
    elif [ "$album" == "" ]; then
        echo "MEDIA STATUS: Active"
        echo "MEDIA METADATA: N/A (Not recognizable as a song)"
    else
        echo "MEDIA STATUS: Active"
        echo "MEDIA METADATA: $track by $artist"
    fi
}

command_to_file "now-playing" "$(render_now_playing)"
command_to_file "memory-usage" "$(render_memory_usage)"
command_to_file "virt-machines" "$(render_vm_stats)"
