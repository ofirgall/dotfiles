#!/usr/bin/env bash

source ~/dotfiles_scripts/helpers/prompt.sh
WORKTREES_ROOT="$HOME/worktrees"

contains() {
	# $1 = list
	# $2 = item
	echo "$1" | grep -w -q "$2"
	return $?
}

get_tmux_sessions() {
	for sess in $(tmux ls -F '#{session_name}'); do
		echo $sess
	done
}

tmux_sessions=$(get_tmux_sessions)

# Iterate over all projects from worktree root
for proj in $(ls "$WORKTREES_ROOT"); do
	echo "--- Cleaning $proj sessions ---"
	proj_dirs=$(ls "$WORKTREES_ROOT/$proj")

	# Iterate over the tmux sessions and remove sessions that has no worktree
	for sess in $tmux_sessions; do
		sess_proj=$(echo "$sess" | sed 's/-.*//g')
		sess_branch=$(echo "$sess" | sed "s/$sess_proj-//")

		if [ "$sess_proj" == "$proj" ]; then
			if ! contains "$proj_dirs" $sess_branch; then
				if yes_no_default_yes "Delete $sess tmux session (missing worktree directory)"; then
					echo "Deleting $sess tmux session"
					tmux kill-session -t "$sess"
				fi
			fi
		fi
	done

	# Iterate over each worktree for that project
	for dir in $proj_dirs; do
		# Check if a session already exist for this project
		if ! contains "$tmux_sessions" "$proj-$dir"; then
			# Session doesn't exist, create a new one
			echo "Create session for $proj-$dir"
			tmux new-session -d -c "$WORKTREES_ROOT/$proj/$dir" -s "$proj-$dir"
		fi
	done
done
