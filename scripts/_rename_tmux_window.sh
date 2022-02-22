#!/bin/bash

PROGRAM_LIMIT=20
PATH_LIMIT=10

pane_id=$1
program=$(ps -f --no-headers --ppid $pane_id | awk '{ print substr($0, index($0,$8)) }')

# No program running, print cd
if [ -z "$program" ]; then
	path=$(tmux display-message -p \#{pane_current_path})
	last_dir=$(basename "$path")
	second_last_dir=$(basename "$(dirname $path)")
	echo "${second_last_dir:0:$PATH_LIMIT}/${last_dir:0:$PATH_LIMIT}"
else
	echo ${program:0:$PROGRAM_LIMIT}
fi
