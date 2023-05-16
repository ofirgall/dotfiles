#!/usr/bin/env bash

set -e

print_usage()
{
	echo "usage: link_env.sh <worktree_dir>"
	exit 0
}

if [[ $@ == *'-h'* ]]; then
	print_usage
fi

if [ "$#" -lt 1 ]; then
	print_usage
fi

if ! test -f $1/.git; then
	echo "$1 isn't a worktree dir"
	exit 1
fi

root_tracked_files="$(git ls-tree `git write-tree` . | awk '{ print $4 }')"

for file in $root_tracked_files; do
    # echo "$file -> $1/$file"
	rm -rf $file
	ln -s $1/$file $file
done
