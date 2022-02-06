#!/bin/bash

# exit if already in tmux
if [ -n "$TMUX" ]; then
	exit 0
fi

select_tmux_session()
{
	session=$(tmux ls -F '#S' | fzf --reverse --header="Select Tmux Session. Ctrl-C to create new session.")

	# ctrl-c
	if [ -z $session ]; then
		return
	fi
	tmux attach -t "$session"
	if [[ "$ZSH_TMUX_ALWAYS_SELECT_SESSION" == "true" ]]; then
		select_tmux_session
	fi
}

select_tmux_session

if [[ "$ZSH_TMUX_ALWAYS_OPEN_SESSION" == "true" ]]; then
	session_name="new-session-$(uuidgen | cut -c1-8)"
	tmux new-session -s $session_name
fi
