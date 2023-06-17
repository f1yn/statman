#! /usr/bin/env bash

# Import dependancies
source "$statman_dir/shared.sh"

##
# Renders the Fedora dnf pending updates information (renders every minute)
# NOTE: This should not be fetching metadata, but just rendering the current state of the package cache
function render_pending_updates() {
    dnf updateinfo
}

##
# Renders public and private IPv4 information
function render_networking() {
    local public_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    local private_ip_addresses="$(hostname -I)"
    
    separator
    echo "${co_label}NETWORKING:$(cor)"
    echo "Public (IPv4): $public_ip"
    echo "Private (IPv4): $private_ip_addresses"
}

command_to_file "pending-updates" "$(render_pending_updates)"
command_to_file "networking" "$(render_networking)"