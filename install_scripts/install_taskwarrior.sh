#!/bin/bash

set -e # Exit if fail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

echo 'Installing Task Warrior'

#.taskrc

download_repo()
{
	# Downloading a github repo
	# $1 - dest dir (recreating it)
	# $2 - github repo e.g: jschlatow/taskopen
	# $3 - git ref
	# $4 - function to call after download inside $1
	local old_pwd=$(pwd)
	rm -rf $1
	mkdir -p $1

	git clone https://github.com/$2 $1

	cd $1
	git checkout $3
	eval $4
	cd $old_pwd
}

build_taskwarrior()
{
	sudo apt-get install -y libgnutls28-dev uuid-dev
	tar -xf task-*
	cd task-*/
	cmake -DCMAKE_BUILD_TYPE=release . && make -j && sudo make install
}

install_taskwarrior-tui()
{
	sudo dpkg -i taskwarrior-tui.deb
}

build_taskwarrior-open()
{
	sudo apt install -y libjson-perl

	make PREFIX=usr
	sudo make PREFIX=usr install
	sudo rm /usr/bin/taskopen
	sudo ln -f -s $HOME/.task/taskopen/taskopen /usr/bin/taskopen
	rm -rf $HOME/tasknotes
	mkdir $HOME/tasknotes
}

download_latest_release /tmp/taskwarrior/ GothenburgBitFactory/taskwarrior task-.* build_taskwarrior
download_latest_release /tmp/taskwarrior-tui/ kdheepak/taskwarrior-tui \.deb install_taskwarrior-tui
download_repo $HOME/.task/taskopen jschlatow/taskopen 0727c460f17967e79b87554edd426a36113f151a build_taskwarrior-open
