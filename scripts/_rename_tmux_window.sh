#!/bin/bash

program=$(ps -f --no-headers --ppid $(tmux display-message -p \#{pane_pid}) | awk '{ print substr($0, index($0,$8)) }')

# No program running, print cd
if [ -z "$program" ]; then
	path=$(tmux display-message -p \#{pane_current_path})
	D2=$(dirname "$path")
	DIRNAME2=$(basename "$D2")/$(basename "$path")
	echo $DIRNAME2
else
	echo $program
fi
