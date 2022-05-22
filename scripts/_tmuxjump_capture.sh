#!/bin/bash

pattern=$1

function capture_panes() {
	local pane captured current_pane
	captured=""
	current_pane=$(tmux display -pt "${TMUX_PANE:?}" '#{pane_index}')

	# Siblings panes
	for pane in $(tmux list-panes -F "#{pane_index}"); do
		if [[ $pane != $current_pane ]]; then
			captured+="$(tmux capture-pane -pJS - -t $pane)"
			captured+=$'\n'
		fi
	done

	# Prev window
	for pane in $(tmux list-panes -F "#{pane_id}" -t -1); do
		captured+="$(tmux capture-pane -pJS - -t $pane)"
		captured+=$'\n'
	done

	# Next window
	for pane in $(tmux list-panes -F "#{pane_id}" -t +1); do
		captured+="$(tmux capture-pane -pJS - -t $pane)"
		captured+=$'\n'
	done

	echo "$captured" | grep -oiE "[\/]?([a-z\_\-]+\/)+[a-z.]+(.)*" | cut -d' ' -f1 | grep "$pattern"
}

capture_panes
