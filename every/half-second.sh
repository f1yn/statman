#! /usr/bin/env bash

# Import dependencies
source "$statman_dir/shared.sh"

##
# Converts the volume from pipewire into a decimal percentage (out of 1)
# 1$:vol {number} The volume expressed as a full percentage
function convert_volume_decimal() {
    local vol=$1
    local volInt=${vol%?} 
    echo "($volInt / 100)" | bc -l
}

##
# Renders the volume as a status bar
function render_volume() {
    local volume="$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}')"
    local volume_decimal=$(convert_volume_decimal $volume)
    local width=$(($columns - 15))
    separator
    echo "${co_label}VOLUME:$(cor) $(bar $width $volume_decimal) $volume"
}

command_to_file "volume" "$(render_volume)"
