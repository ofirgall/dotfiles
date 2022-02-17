#!/bin/bash

START_DIR=$HOME/workspace

original_pwd=$(pwd)

choose_dir()
{
	path=$(ls -d */ | fzf --reverse --header="$(pwd)/ (Ctrl-C to abort, Ctrl-X to exit)" --height=30 --bind "ctrl-x:abort+execute(echo ___exit)")

	# ctrl-c
	if [ -z $path ]; then
		cd $original_pwd
		return
	fi

	# ctrl-z
	if [ $path == "___exit" ]; then
		return
	fi

	cd $path
	if [ -d ".git" ]; then
		return
	fi
	choose_dir
}

cd $START_DIR
choose_dir
pwd
