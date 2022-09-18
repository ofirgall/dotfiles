#!/bin/bash

# cd to git repos with fzf menus
# usage: cg - starts from $START_DIR
#		 cg ~/dir - starts from ~/dir

START_DIR=$HOME/workspace

original_pwd=$(pwd)

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

ls_with_branch()
{
	for i in $(ls -d */); do echo "$i ($(get_branch $i))"; done
}

choose_dir()
{
	# No dirs
	if ! ls -d */ &> /dev/null; then
		return
	fi

	if [ -d ".git" ] || [ -f ".git" ]; then
		return
	fi

	result=$(ls_with_branch | fzf --reverse --header="$(pwd)/ (Ctrl-C to abort, Ctrl-X to exit)" --height=30 --bind "ctrl-x:abort+execute(echo ___exit)")

	# ctrl-c
	if [ -z "$result" ]; then
		cd $original_pwd
		return
	fi

	# ctrl-z
	if [ "$result" == "___exit" ]; then
		return
	fi

	path=$(echo "$result" | sed "s/ (.*//")
	cd "$path"
	choose_dir
}

if [ "$#" -eq 1 ]; then
	cd $1
else
	cd $START_DIR
fi
choose_dir
pwd # echo pwd at end (to cd later)
