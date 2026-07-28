#!/bin/bash
# Detect displays and cache results for sketchybarrc to read.
# Called at startup and on display_change events.
# Cache format: line 1 = built-in display ID, line 2 = comma-separated external IDs
# Uses sketchybar arrangement IDs (not aerospace AppKit IDs).
# Exits 1 if nothing changed (caller can skip reload).

CACHE="/tmp/sketchybar-display-info"

BUILTIN_DISPLAY=""
EXTERNAL_DISPLAYS=""

DISPLAYS=$(sketchybar --query displays 2>/dev/null)
if [ -z "$DISPLAYS" ]; then
    exit 1
fi

BUILTIN_W=1512
BUILTIN_H=982

while IFS=$'\t' read -r aid w h; do
    if [ "$w" = "$BUILTIN_W" ] && [ "$h" = "$BUILTIN_H" ]; then
        BUILTIN_DISPLAY="$aid"
    else
        EXTERNAL_DISPLAYS="${EXTERNAL_DISPLAYS:+$EXTERNAL_DISPLAYS,}$aid"
    fi
done < <(echo "$DISPLAYS" | jq -r '.[] | [.["arrangement-id"], (.frame.w | floor), (.frame.h | floor)] | @tsv')

NEW_CONTENT=$(printf '%s\n%s\n' "$BUILTIN_DISPLAY" "$EXTERNAL_DISPLAYS")

if [ -f "$CACHE" ] && [ "$(cat "$CACHE")" = "$NEW_CONTENT" ]; then
    exit 1
fi

printf '%s' "$NEW_CONTENT" > "$CACHE"
