#!/usr/bin/env bash

set -e

source ~/dotfiles_scripts/helpers/git.sh

print_usage() {
	echo "usage: link_env.sh <worktree_dir>"
	exit 0
}

if [[ $@ == *'-h'* ]]; then
	print_usage
fi

worktree_path=""

if [ "$#" -lt 1 ]; then
	worktree_path=$(get_worktree_from_tmux)
	echo "Worktree path: $worktree_path"
else
	worktree_path=$1
fi

if ! test -f $worktree_path/.git; then
	echo "$worktree_path isn't a worktree dir"
	exit 1
fi

root_tracked_files="$(git ls-tree $(git write-tree) . | awk '{ print $4 }')"

for file in $root_tracked_files; do
	# echo "$file -> $1/$file"
	rm -rf $file
	ln -s $worktree_path/$file $file
done

# Save the basename of the worktree to make starship display it
echo $(basename "$worktree_path") > .linked_env
