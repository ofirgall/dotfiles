#!/bin/bash

pattern=$1
PANE_FORMAT="#{pane_id}|#{pane_current_path}"

function echo_pane () {
	pane_id=$(echo "$1" | cut -d'|' -f1)
	pane_path=$(echo "$1" | cut -d'|' -f2)
	captured="$(tmux capture-pane -pJS - -t $pane_id)"
	cd $pane_path
	# echo "$captured" | grep -oiE "[\/]?([a-z\_\-\.]+\/)+[a-z.]+(.)*" | cut -d' ' -f1 | grep "$pattern" | grep ":[0-9]" | sed -E 's/([0-9]+:[0-9]+).+/\1/' | xargs realpath 2> /dev/null
	echo "$captured" | grep -oiE ".+\..+:[0-9]+(:[0-9]+)?" | grep "$pattern" | xargs realpath 2> /dev/null
}

function capture_panes() {
	local pane captured current_pane
	current_pane=$(tmux display -pt "${TMUX_PANE:?}" '#{pane_id}')
	captured=""

	# Siblings panes
	for pane in $(tmux list-panes -F "$PANE_FORMAT"); do
		if [[ $pane != $current_pane ]]; then
			captured+="$(echo_pane "$pane")"
			captured+=$'\n'
		fi
	done

	window_count=$(tmux list-windows | wc -l)
	if [ $window_count -gt 1 ]; then
		# Prev window
		for pane in $(tmux list-panes -F "$PANE_FORMAT" -t -1); do
			captured+="$(echo_pane "$pane")"
			captured+=$'\n'
		done
	fi

	if [ $window_count -gt 2 ]; then
		# Next window
		for pane in $(tmux list-panes -F "$PANE_FORMAT" -t +1); do
			captured+="$(echo_pane "$pane")"
			captured+=$'\n'
		done
	fi

	echo "$captured" | sort | uniq
}

capture_panes
