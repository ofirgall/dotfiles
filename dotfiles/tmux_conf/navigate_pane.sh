#!/usr/bin/env sh

direction="$1"

case "$direction" in
    left)  tmux_flag="-L"; hypr_dir="l" ;;
    right) tmux_flag="-R"; hypr_dir="r" ;;
    up)    tmux_flag="-U"; hypr_dir="u" ;;
    down)  tmux_flag="-D"; hypr_dir="d" ;;
    *) echo "Usage: $0 <left|right|up|down>" >&2; exit 1 ;;
esac

if [ -n "$TMUX" ]; then
    case "$direction" in
        left)  at_edge=$(tmux display-message -p '#{pane_at_left}') ;;
        right) at_edge=$(tmux display-message -p '#{pane_at_right}') ;;
        up)    at_edge=$(tmux display-message -p '#{pane_at_top}') ;;
        down)  at_edge=$(tmux display-message -p '#{pane_at_bottom}') ;;
    esac

    if [ "$at_edge" != "1" ]; then
        tmux select-pane $tmux_flag
        exit 0
    fi
fi

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    hyprctl dispatch movefocus "$hypr_dir" > /dev/null
fi

exit 0
