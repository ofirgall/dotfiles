#!/usr/bin/env bash

# Change http remote to ssh

if [ ! -z "$1" ]; then
	origin=$1
else
	origin=origin
fi

ssh_url=$(git remote -v | grep "$origin" | grep fetch | sed -e "s/$origin\t//" | sed -e 's/ (fetch)//' | sed -e 's,https://github.com/,git@github.com:,')

echo "# New remote: $ssh_url"
git remote set-url $origin $ssh_url

echo
echo "# Setting git user"
set_git_user.sh
