#!/bin/bash

# exit if already in tmux
if [ -n "$TMUX" ]; then
	exit 0
fi

TMUX_RESERRUCT_DIR=$HOME/.tmux/resurrect
source $HOME/dotfiles_scripts/helpers/git.sh

tmux_ressurect_sessions()
{
	cat $1 | cut -f 2 | sort | uniq
}

echo_title()
{
	echo "------------------- $1 -------------------"
}

before_after_prompt()
{
	read -p "Select sessions to reserruct [b/a] " -r
	echo
	if [[ $REPLY =~ ^[Bb]$ ]]; then
		echo "b"
	elif [[ $REPLY =~ ^[Aa]$ ]]; then
		echo "a"
	else
		before_after_prompt
	fi
}

fix_reserruct()
{
	file_before_uptime=$(find $TMUX_RESERRUCT_DIR -type f \! -newermt "$(uptime -s)" | grep -v last | xargs -r ls -rt | tail -n 1)
	file_after_uptime=$(find $TMUX_RESERRUCT_DIR -type f -newermt "$(uptime -s)" | grep -v last | xargs -r ls -rt | tail -n 1)

	if [ -z $file_before_uptime ]; then
		return
	fi

	if [ -z $file_after_uptime ]; then
		rm $TMUX_RESERRUCT_DIR/last
		echo "Linking $TMUX_RESERRUCT_DIR/last -> $file_before_uptime"
		ln -s $file_before_uptime $TMUX_RESERRUCT_DIR/last
		return
	fi

	echo_title "SESSIONS BEFORE BOOT ($file_before_uptime)"
	echo "$(tmux_ressurect_sessions $file_before_uptime)"

	echo_title "SESSIONS AFTER BOOT ($file_after_uptime)"
	echo "$(tmux_ressurect_sessions $file_after_uptime)"

	before_after=$(before_after_prompt)
	rm $TMUX_RESERRUCT_DIR/last
	if [ $before_after == "b" ]; then
		echo "Linking $TMUX_RESERRUCT_DIR/last -> $file_before_uptime"
		ln -s $file_before_uptime $TMUX_RESERRUCT_DIR/last
	else
		echo "Linking $TMUX_RESERRUCT_DIR/last -> $file_after_uptime"
		ln -s $file_after_uptime $TMUX_RESERRUCT_DIR/last
	fi
}

get_session_git_info()
{
	session="$1"
	path="$(tmux display-message -t $session:1 -p '#{pane_current_path}')"
	git_root=$(get_git_root $path)

	# TODO: show git dir?
	echo $(get_branch $git_root)
}

tmux_sessions_with_git_info()
{
	sessions=$(tmux ls -F '#S')
	for session in $sessions; do
		echo "$session ($(get_session_git_info $session))"
	done
}

select_tmux_session()
{
	# Check if tmux server is running, run it otherwise
	if ! tmux ls &> /dev/null; then
		if [ -d "$TMUX_RESERRUCT_DIR" ]; then
			echo "No tmux server, lets choose the resseruct file first."
			fix_reserruct
		fi
		tmux
	fi

	session=$(tmux_sessions_with_git_info | fzf --reverse --header="Select Tmux Session. Ctrl-f to Create New Session, Ctrl-C to exit." --bind "ctrl-f:abort+execute(echo ___new_session)")

	# ctrl-c
	if [ -z "$session" ]; then
		return
	fi

	# Strip git info
	session=$(echo "$session" | sed "s/ (.*//")

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
