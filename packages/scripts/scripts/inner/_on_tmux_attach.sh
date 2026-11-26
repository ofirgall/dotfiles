#!/bin/bash

if test -f "$HOME/.remote_indicator"; then
	exit 0
fi

open_browser()
{
	$HOME/.tmux/plugins/tmux-browser/scripts/open_browser.sh
}

current_session=$(tmux display-message -p '#S')

if [ "$current_session" == "main" ]; then
	# slack # open slack
	teams # open teams :(
	open_browser # open browser (mail & calander)
	spotify
fi

# if echo "$current_session" | grep -q "^vol-"; then
# 	$HOME/.tmux/plugins/tmux-browser/scripts/open_browser.sh
# fi
