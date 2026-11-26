#!/usr/bin/env sh

amount_of_panes=$(tmux list-panes | wc -l)
amount_of_windows=$(tmux list-windows | wc -l)

if [ $amount_of_panes -eq 1 ] && [ $amount_of_windows -eq 1 ]; then
    exit
fi

tmux kill-pane
