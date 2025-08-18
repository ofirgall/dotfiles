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

BRANCH_COLOR="\033[1;36m"
RESET_COLOR="\033[0m"

tmux_sessions_with_git_info()
{
	sessions=$(tmux ls -F '#S')
	for session in $sessions; do
		if echo "$session" | grep -q "\-viewer"; then
			continue
		fi
		echo -e "$session $BRANCH_COLOR($(get_session_git_info $session))$RESET_COLOR"
	done
}

clean_viewer_sessions()
{
	viewer_session_not_attached=$(tmux ls | grep "\-viewer" | grep -v attached)
	if [ -z "$viewer_session_not_attached" ]; then
		return
	fi
	while IFS= read -r line; do
		session=$(echo "$line" | grep -o -E ".+: " | sed -e "s/: //")
		tmux kill-session -t $session
	done <<< "$viewer_session_not_attached"
}

SESSION_MODE_FILE=/tmp/.select_tmux_session_mode

select_tmux_session()
{
	# Check if tmux server is running, run it otherwise
	if ! tmux ls &> /dev/null; then
		if [ -d "$TMUX_RESERRUCT_DIR" ]; then
			echo "No tmux server, lets choose the resseruct file first."
			fix_reserruct
		fi
		echo "Waiting for tmux tmux-ressurct"
		timeout 10 tmux &> /dev/null

		# Wait for tmux-ressurct to restore
		until [ -f /tmp/tmux_ressurect_done ]; do sleep 0.05; done
	fi

	if [ ! -z $ATTACH_TO ]; then
		_ATTACH_TO=$ATTACH_TO
		unset $ATTACH_TO
		tmux attach -t $_ATTACH_TO
	fi

	clean_viewer_sessions

	echo "attach" > $SESSION_MODE_FILE
	session=$(tmux_sessions_with_git_info | fzf --reverse --header="Select Tmux Session. Ctrl-f to Create New Session, Ctrl-v to create 'viewer' session, Ctrl-C to exit." --ansi --bind "ctrl-f:become(echo ___new_session)+abort" --bind "ctrl-v:execute(echo viewer > $SESSION_MODE_FILE)+accept")

	# ctrl-c
	if [ -z "$session" ]; then
		return
	fi

	# Strip git info
	session=$(echo "$session" | sed "s/ (.*//")

	if [ "$session" == "___new_session" ]; then
		tmux new-session -s "new-session-$(uuidgen | cut -c1-8)"
	else
		mode=$(cat $SESSION_MODE_FILE)

		if [ "$mode" == "attach" ]; then
			# Attach to session
			tmux attach -t "$session"
		elif [ "$mode" == "viewer" ]; then
			echo "hey"
			if tmux ls | grep "$session-viewer"; then
				# If for some reason there is a viewer session attach to it
				tmux attach -t "$session-viewer"
			else
				# Create new viewer session
				tmux new-session -s "$session-viewer" -t "$session"
			fi
		fi
	fi

	if [[ "$ZSH_TMUX_ALWAYS_SELECT_SESSION" == "true" ]]; then
		select_tmux_session
	fi
}

select_tmux_session
