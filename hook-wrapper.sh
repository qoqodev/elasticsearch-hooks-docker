#!/bin/bash

start() {
    [ -f "/hooks/prestart" ] && /hooks/prestart || eval $prestart_hook
    $entrypoint_original $cmd_original &
    pid="$!"
    [ -f "/hooks/poststart" ] && /hooks/poststart || eval $poststart_hook
    wait
}

stop() {
    signal="$1"
    [ -f "/hooks/prestop" ] && /hooks/prestop || eval $prestop_hook
    kill -$signal $pid
    [ -f "/hooks/poststop" ] && /hooks/poststop || eval $poststop_hook
}

# a handler f passed to trapf will get the trap signal as its first argument
trapf() {
    f="$1"; shift
    for signal in "$@"; do
        trap "$f $signal" "$signal"
    done
}

if [ "$@" == "$cmd_original" ]; then
    trapf stop $trap_signals
    start
else
    $entrypoint_original "$@"
fi
