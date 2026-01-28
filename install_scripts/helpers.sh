#!/bin/bash

IS_REMOTE=false
if test -f "$HOME/.remote_indicator"; then
  IS_REMOTE=true
fi

# TODO: utilize this if needed someday
IS_APT=false
if [ -n "$(command -v apt-get)" ]; then
	IS_APT=true
fi

NO_SUDO=false
if test -f "$HOME/.no_sudo_indicator"; then
  NO_SUDO=true
fi

WSL=false
if [[ $(uname -a) == *"Microsoft"* ]]; then
	WSL=true
fi

download_latest_release()
{
	# Downloading a github release file
	# $1 - dest dir (recreating it)
	# $2 - github repo e.g: GothenburgBitFactory/taskwarrior
	# $3 - grep match file e.g: task-.*
	# $4 - function to call after download inside $1

	local old_pwd=$(pwd)
	rm -rf $1
	mkdir -p $1

	local res=$(curl -L -s https://api.github.com/repos/$2/releases/latest)
	local url=$(echo "$res"| grep "browser_download_url.*$3" | cut -d : -f 2,3 | tr -d \")
	echo "Downloading $1 from '$url'"
	if [ -z "$url" ]; then
		echo "URL is empty, res: '$(echo "$res" | grep browser_download_url)'"
		return 1
	fi
	wget -P $1 -q $url

	cd $1
	eval $4
	cd $old_pwd
}
