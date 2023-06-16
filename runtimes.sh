#! /usr/bin/env bash

# TODO: Module description

statman_dir="$(dirname -- "$0")"
source $statman_dir/shared.sh

## Runtimes
function statman_every_half_second() (
    set -e
    # This first sleep statement is here to allow the term to set
    # the correct values for scaling, e.c.t
    sleep .5
    while true; do
        # minimum wait time for each iteraction
        sleep .5 &
        sh "$statman_dir/every/half-second.sh"
        wait
    done
)

function statman_every_two_seconds() (
    set -e
    sleep .5
    while true; do
        # minimum wait time for each iteraction
        sleep 2 &
        sh "$statman_dir/every/two-seconds.sh"
        wait
    done
)

function statman_every_second() (
    set -e
    sleep .5
    while true; do
        # minimum wait time for each iteraction
        sleep 1 &
        sh "$statman_dir/every/second.sh"
        wait
    done
)

function statman_every_minute() (
    set -e
    sleep .5
    while true; do
        # minimum wait time for each iteraction
        sleep 60 &
        sh "$statman_dir/every/minute.sh"
        wait
    done
)

function statman_every_five_minutes() (
    set -e
    sleep .5
    while true; do
        # minimum wait time for each iteraction
        sleep 300 &
        sh "$statman_dir/every/five-minutes.sh"
        wait
    done
)
