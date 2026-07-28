#!/bin/bash
# Detect displays and cache results for sketchybarrc to read.
# Called at startup and on display_change events.
# Cache format: line 1 = built-in display ID, line 2 = comma-separated external IDs
# Exits 1 if nothing changed (caller can skip reload).

CACHE="/tmp/sketchybar-display-info"

BUILTIN_DISPLAY=""
EXTERNAL_DISPLAYS=""

while IFS=" " read -r sb_id name; do
  if [[ "$name" == *"Built-in"* ]]; then
    BUILTIN_DISPLAY="$sb_id"
  else
    EXTERNAL_DISPLAYS="${EXTERNAL_DISPLAYS:+$EXTERNAL_DISPLAYS,}$sb_id"
  fi
done < <(aerospace list-monitors --format '%{monitor-appkit-nsscreen-screens-id} %{monitor-name}' 2>/dev/null)

NEW_CONTENT=$(printf '%s\n%s\n' "$BUILTIN_DISPLAY" "$EXTERNAL_DISPLAYS")

if [ -f "$CACHE" ] && [ "$(cat "$CACHE")" = "$NEW_CONTENT" ]; then
    exit 1
fi

printf '%s' "$NEW_CONTENT" > "$CACHE"
