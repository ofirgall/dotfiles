#!/bin/bash
# For each window in every session:
#   - If @window_color is set: resolve it to hex (bright) and write
#     @window_color and @window_color_dim so both live in the same
#     palette. Bright = factor 1.0, dim = factor 0.5.
#   - If @window_color is unset: unset @window_color_dim too.
# This way external callers can write @window_color as a name (red,
# mauve, ...) or hex, and we normalize. Active and inactive bg always
# read as bright/dim variants of the same hue.
dir="$(dirname "$0")"
while IFS=$'\t' read -r wid color; do
  if [[ -n "$color" ]]; then
    bright=$("$dir/dim_color.sh" "$color" 1.0)
    dim=$("$dir/dim_color.sh" "$color" 0.5)
    # Only rewrite @window_color if it changed (avoid hook loops).
    if [[ "$color" != "$bright" ]]; then
      tmux setw -t "$wid" @window_color        "$bright"
    fi
    tmux setw -t "$wid" @window_color_dim "$dim"
  else
    tmux setw -t "$wid" -u @window_color_dim 2>/dev/null
  fi
done < <(tmux list-windows -a -F '#{window_id}	#{@window_color}')
