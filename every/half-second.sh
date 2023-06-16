#! /usr/bin/env bash

# Import dependancies
current_dir="$(dirname -- "$0")"
source "$current_dir/../shared.sh"

# Function
function convert_volume_decimal() {
    local vol=$1
    local volInt=${vol%?} 
    echo "($volInt / 100)" | bc -l
}

function render_volume() {
    local volume="$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}')"
    local volume_decimal=$(convert_volume_decimal $volume)
    local width=$(($columns - 15))
    separator
    co 0
    echo "${co_label}VOLUME:$(cor) $(bar $width $volume_decimal) $volume"
}

command_to_file "volume" "$(render_volume)"
