#!/bin/bash

# cd to git repos with fzf menus
# usage: cg - starts from $START_DIR
#		 cg ~/dir - starts from ~/dir

START_DIR=$HOME/workspace
source $HOME/dotfiles_scripts/helpers/git.sh

original_pwd=$(pwd)

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
