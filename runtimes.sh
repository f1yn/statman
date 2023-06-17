#! /usr/bin/env bash

source "$statman_dir/shared.sh"

###
### RUNTIMES
### Each of the below functions is responsible for generating the outputs needed for statman. Each has it's
### own specified time period. Statman will then scan the outputs and concatenate them in it's output (see render.sh)
### For ease of documentation, each function in this file represents a subshell that would be used like
###
###   statman_every_half_second &

function statman_every_half_second() (
    # Don't exit on errors
    set +e
    # This first sleep statement is here to allow the term to set
    # the correct values for scaling, e.c.t
    sleep .5
    while true; do
        sleep .5 &
        # The minimum execution window - we wait for the sleep to finish executing
        sh "$statman_dir/every/half-second.sh"
        wait
    done
)

function statman_every_two_seconds() (
    set +e
    sleep .5
    while true; do
        sleep 2 &
        sh "$statman_dir/every/two-seconds.sh"
        wait
    done
)

function statman_every_five_seconds() (
    set +e
    sleep .5
    while true; do
        sleep 5 &
        sh "$statman_dir/every/five-seconds.sh"
        wait
    done
)

function statman_every_second() (
    set -e
    sleep .5
    while true; do
        sleep 1 &
        sh "$statman_dir/every/second.sh"
        wait
    done
)

function statman_every_minute() (
    set +e
    sleep .5
    while true; do
        sleep 60 &
        sh "$statman_dir/every/minute.sh"
        wait
    done
)

function statman_every_five_minutes() (
    set +e
    sleep .5
    while true; do
        sleep 300 &
        sh "$statman_dir/every/five-minutes.sh"
        wait
    done
)
