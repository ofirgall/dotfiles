#!/bin/bash

if test -f "$HOME/.remote_indicator"; then
	exit 0
fi

current_session=$(tmux display-message -p '#S')

if [ "$current_session" == "main" ]; then
	slack # open slack
	$HOME/.tmux/plugins/tmux-browser/scripts/open_browser.sh # open browser (mail & calander)
fi
