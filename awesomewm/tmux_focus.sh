#!/usr/bin/env bash

# Wrapper script for awesomewm-vim-tmux-navigator/tmux_focus.sh

dir=$1
if [[ "$XDG_SESSION_DESKTOP" == "awesome" ]]; then
    $HOME/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh "$dir"
else
    case "$dir" in
        "left")
            tmux select-pane -L ;;
        "right")
            tmux select-pane -R ;;
        "up")
            tmux select-pane -U ;;
        "down")
            tmux select-pane -D ;;
    esac
fi
