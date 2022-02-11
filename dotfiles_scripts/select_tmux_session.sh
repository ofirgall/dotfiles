#!/bin/bash

# exit if already in tmux
if [ -n "$TMUX" ]; then
	exit 0
fi

select_tmux_session()
{
	session=$(tmux ls -F '#S' | fzf --reverse --header="Select Tmux Session. Ctrl-f to Create New Session, Ctrl-C to exit." --bind "ctrl-f:abort+execute(echo ___new_session)")

	# ctrl-c
	if [ -z $session ]; then
		return
	fi

	if [ "$session" == "___new_session" ]; then
		tmux new-session -s "new-session-$(uuidgen | cut -c1-8)"
	else
		# Attach to session
		tmux attach -t "$session"
	fi

	if [[ "$ZSH_TMUX_ALWAYS_SELECT_SESSION" == "true" ]]; then
		select_tmux_session
	fi
}

select_tmux_session
