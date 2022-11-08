#!/bin/bash

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
	cd $1
	(git rev-parse --show-toplevel 2> /dev/null || pwd)
}
