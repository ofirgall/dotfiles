#!/usr/bin/env bash

# Usage: ./helpers.sh <func> <func args>

function get_pid_in_pane() {
    local tty=$1
    echo "$(ps -f -t $tty | tail -n 1 | tr -s ' ' | cut -f2 -d ' ')"
}

function get_ssh_cmd_in_pane() {
    local tty=$1
    local pid=$(get_pid_in_pane $tty)

    local ssh_cmd=$(cat /proc/$pid/cmdline | sed -e "s/\x00/' '/g" | sed "s/' / /" | sed "s/'$//")
    echo $ssh_cmd
}

function get_ssh_host_in_pane() {
    local tty=$1
    local pid=$(get_pid_in_pane $tty)

    local ssh_cmd=$(cat /proc/$pid/cmdline | sed -e "s/\x00/ /g")
    if ! echo "$ssh_cmd" | cut -d ' ' -f1 | grep "ssh" &> /dev/null; then
        # Not a ssh command
        return
    fi

    local ssh_args=$(echo "$ssh_cmd" | cut -d ' ' -f2-)

    for arg in $ssh_args; do
        # Skip flags
        if [[ ${arg:0:1} == "-" ]]; then
            continue
        fi

        echo $arg
        return
    done
}

if [ "$#" -ge 1 ]; then
    func=$1
    shift
    $func $@
fi
