#!/usr/bin/env bash

# Add `fork` remote

# git remote -v | grep origin | grep fetch | sed -e 's/origin\t//' | sed -e 's/ (fetch)//' | sed -e 's,https://github.com/\(.*\)/\(.*\),\1\2,'

if [ ! -z "$1" ]; then
	origin=$1
else
	origin=origin
fi

repo=$(git remote -v | grep "$origin" | grep fetch | sed -e "s/$origin\t//" | sed -e 's/ (fetch)//' | sed -e 's,https://github.com/\(.*\)/\(.*\),\2,')

fork_url=git@github.com:ofirgall/$repo

echo "Adding $fork_url as 'fork'"

git remote add fork $fork_url
