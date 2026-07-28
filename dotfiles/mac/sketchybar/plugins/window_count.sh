#!/bin/bash

# Derive suffix from $NAME (set by sketchybar to the triggering item name)
# e.g. "window_count.builtin" → ".builtin", "window_count" → ""
SUFFIX=""
case "$NAME" in
    *.*) SUFFIX=".${NAME#*.}" ;;
esac

# Find the display key with valid coordinates for this item
find_display_key() {
    local item_data="$1"
    echo "$item_data" | jq -r '
        .bounding_rects | to_entries[]
        | select(.value.origin[0] > -9000)
        | .key' | head -1
}


COUNT=$(aerospace list-windows --workspace focused 2>/dev/null | wc -l | tr -d ' ')
WINDOW_TITLE=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)

    case "$LAYOUT" in
        *accordion*) COLOR=0xff94e2d5 ;;  # teal — maximized
        *)           COLOR=0xffcba6f7 ;;  # mauve — tiled
    esac

    # Dynamically limit window_name so right-side items don't overlap workspaces.
    # Calculate where window_count would be WITHOUT window_name, then budget
    # the remaining space for the name label.
    MAX_CHARS=50
    SHOW_NAME=on
    FOUND_WS=""
    LAST_WS_RIGHT=0
    for sid in 10 9 8 7 6 5 4 3 2 1; do
        WS_DATA=$(sketchybar --query "space.${sid}${SUFFIX}" 2>/dev/null) || continue
        [ "$(echo "$WS_DATA" | jq -r '.geometry.drawing')" = "on" ] || continue
        DK=$(find_display_key "$WS_DATA")
        [ -n "$DK" ] || continue
        WS_X=$(echo "$WS_DATA" | jq ".bounding_rects[\"$DK\"].origin[0]")
        WS_W=$(echo "$WS_DATA" | jq ".bounding_rects[\"$DK\"].size[0]")
        LAST_WS_RIGHT=$(echo "$WS_X + $WS_W" | bc)
        FOUND_WS=1
        break
    done
    if [ -n "$FOUND_WS" ]; then
        WC_DATA=$(sketchybar --query "window_count${SUFFIX}" 2>/dev/null)
        DK=$(find_display_key "$WC_DATA")
        WC_X=$(echo "$WC_DATA" | jq ".bounding_rects[\"${DK:-display-1}\"].origin[0] // 0")
        WN_DATA=$(sketchybar --query "window_name${SUFFIX}" 2>/dev/null)
        WN_DRAWING=$(echo "$WN_DATA" | jq -r '.geometry.drawing')
        WN_W=$(echo "$WN_DATA" | jq ".bounding_rects[\"${DK:-display-1}\"].size[0] // 0")
        if [ "$WN_DRAWING" = "on" ]; then
            WC_X_BASE=$(echo "$WC_X + $WN_W" | bc)
        else
            WC_X_BASE="$WC_X"
        fi
        GAP=10
        AVAIL=$(echo "$WC_X_BASE - $LAST_WS_RIGHT - $GAP" | bc | awk '{printf "%d", $1}')
        CHAR_W=7
        if (( AVAIL < CHAR_W * 3 )); then
            SHOW_NAME=off
        else
            MAX_CHARS=$(( AVAIL / CHAR_W ))
            if (( MAX_CHARS > 50 )); then MAX_CHARS=50; fi
        fi
    fi

    sketchybar --set "window_count${SUFFIX}" label="${COUNT}" drawing=on icon.color="$COLOR" label.color="$COLOR"
    if [ "$SHOW_NAME" = "on" ]; then
        sketchybar --set "window_name${SUFFIX}" label="${WINDOW_TITLE}" drawing=on label.color="$COLOR" label.max_chars="$MAX_CHARS"
    else
        sketchybar --set "window_name${SUFFIX}" drawing=off
    fi
else
    sketchybar --set "window_count${SUFFIX}" drawing=off \
               --set "window_name${SUFFIX}" drawing=off
fi
