#!/bin/bash

set -e # Exit if fail

print_usage()
{
	echo "usage: compare_rebased_branch.sh <commit-hash-1> <commit-hash-2>"
	echo ""
	echo "Compare the same branch after rebase, shows diff of between the commits after the conflict solve"
	echo ""
	echo "Examples:"
	echo "	compare_rebased_branch.sh after_rebase before_rebase"
	echo ""
	exit 0
}

escape_filename()
{
	echo $1 | sed -e "s,/,_,g"
}

# Makes a tmp dir with all the commits in $1..$2
# returns: the tmp dir
make_commits_dir()
{
	suffix=$(escape_filename $(echo "_$2")) # change / to _
	tmp_dir=$(mktemp -d --suffix="$suffix")
	while read -r hash_msg; do
		hash=$(echo "$hash_msg" | cut -f1 -d" ")
		msg=$(echo "$hash_msg" | cut -f2- -d" ")
		msg=$(escape_filename "$msg")

		# unifed=0 -> only changed lines
		git show $hash --unified=0 --output="$tmp_dir/$msg"

		# Remove stuff from patch file to match other patches:
		#	* First line (commit <hash>)
		#	* index <hash>..<hash> line
		#	* @@ 14,3-23, @@
		sed -i '1d;/index [a-f0-9].*\.\.[a-f0-9].*/d;/@@ [-+,0-9].* @@/d' "$tmp_dir/$msg"
	done < <(git log --format="%H %s" $1..$2)
	echo "$tmp_dir"
}

if [[ $@ == *'-h'* ]]; then
	print_usage
fi

if [ "$#" -lt 2 ]; then
	print_usage
fi

GIT_LOG='git --no-pager log --pretty=format:"%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red)[%an]%C(reset)%C(blue)%d%C(reset)" --date=short'

merge_base=$(git merge-base $1 $2)
echo "=== BASE ==="
eval "$GIT_LOG $merge_base^..$merge_base"
echo

first_dir=$(make_commits_dir $merge_base $1)
second_dir=$(make_commits_dir $merge_base $2)

echo
echo "=== Done ==="
echo "Created $first_dir and $second_dir"
meld $first_dir $second_dir
