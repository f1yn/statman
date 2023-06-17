#! /usr/bin/env bash

# Import dependencies
source "$statman_dir/shared.sh"

##
# Renders the current system memory utilization as a progress bar
function render_memory_usage() {
    local memory_decimal=$(free | grep Mem | awk '{print $3/$2}')
    local memory=$(echo "scale=0; ($memory_decimal * 100) / 1" | bc)
    local width=$(($columns - 15))

    separator
    echo "${co_label}MEMORY:$(cor) $(bar $width $memory_decimal) $memory%"
}

##
# Renders a list of currently active QEMU virtual machines by checking the progress log
# QEMU/libvirt is very generous, and the process metadata for these systems will have most
# of the information that we need, like name, device allocations, e.c.t - without needing superuser
function render_vm_stats() {
    # First or last line will contain the grep, so avoid that line
    local all_virt_sessions="$(ps aux | grep -i qemu-system- | grep -v 'grep')"
    local session_names="$(echo "$all_virt_sessions" | awk -F[=,] '{print $2}')"
    local session_count="$(echo "$session_names" | wc -w)"

    # TODO: Determine status for each VM by checking their CPU states and stats
    # If a process has not spiked recently, it's likely disabled
    # If it's had some activity, it's probably idle
    # Otherwise it's active

    # TODO: Add jq to read things like VFIO PCI allocations from the config that
    # gets added in the ps output. It would be nice to see what pci devices are
    # being used. This might mean we move this to a 5 second runtime though 

    separator
    echo "${co_label}VIRTUAL MACHINES:$(cor) ($session_count enabled)"

    for i in $session_names; do
        echo "- $i"
    done
}

##
# Renders the current metadata of media. Unlike a lot of Now Playing implementations, this one
# will try and skip rendering information for things we can't confirm to be music (which is usually
# indicated by the lack of an artist in metadata - which is the case for things like videos and sites)
function render_now_playing() {
    local artist="$(playerctl metadata artist 2>/dev/null)"
    local album="$(playerctl metadata album 2>/dev/null)"
    local track="$(playerctl metadata title 2>/dev/null)"

    separator

    if [ "$artist" == "" ]; then
        echo "${co_label}MEDIA STATUS:$(cor) Inactive"
        echo "${co_label}MEDIA METADATA:$(cor) Inactive"
    elif [ "$album" == "" ]; then
        echo "${co_label}MEDIA STATUS:$(cor) Active"
        echo "${co_label}MEDIA METADATA:$(cor) N/A (Not recognizable as a song)"
    else
        echo "${co_label}MEDIA STATUS:$(cor) Active"
        echo "${co_label}MEDIA METADATA:$(cor) $track by $artist"
    fi
}

command_to_file "now-playing" "$(render_now_playing)"
command_to_file "memory-usage" "$(render_memory_usage)"
command_to_file "virt-machines" "$(render_vm_stats)"
