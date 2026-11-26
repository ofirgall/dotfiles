#!/bin/bash

WORKTREES_ROOT="$HOME/worktrees"

get_branch()
{
	# $1: dir
	git_dir=""
	if [ -d "$1/.git" ]; then
		git_dir="$1/.git"
	elif [ -f "$1/.git" ]; then # worktree
		git_dir=$(cat "$1/.git" | sed 's/gitdir: //')
	else
		return
	fi

	cat "$git_dir/HEAD" 2> /dev/null | sed 's,ref: refs/heads/,,'
}

get_git_root()
{
	# $1: dir

	if [ ! -d "$1" ]; then
		# not a directory
		return
	fi
	cd $1
	(git rev-parse --show-toplevel 2> /dev/null || pwd)
}

get_worktree_from_tmux() {
	if [ -z $TMUX ]; then
		exit 1
	fi
	tmux_session=$(tmux display-message -p '#S')
	echo "$WORKTREES_ROOT/$(echo "$tmux_session" | sed 's,-,/,g')"
}
