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
