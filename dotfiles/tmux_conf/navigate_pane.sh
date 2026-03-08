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
    current_pane=$(tmux display-message -p '#D')
    tmux select-pane $tmux_flag
    new_pane=$(tmux display-message -p '#D')
    [ "$current_pane" != "$new_pane" ] && exit 0
fi

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    hyprctl dispatch movefocus "$hypr_dir" > /dev/null
fi

exit 0
