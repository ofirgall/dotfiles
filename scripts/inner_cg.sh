#!/bin/bash

START_DIR=$HOME/workspace

original_pwd=$(pwd)

ls_with_branch()
{
	 for i in $(ls -d */); do echo "$i ($(cat $i/.git/HEAD 2> /dev/null | sed 's,ref: refs/heads/,,'))"; done
}

choose_dir()
{
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
	if [ -d ".git" ]; then
		return
	fi
	choose_dir
}

cd $START_DIR
choose_dir
pwd
