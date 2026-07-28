#!/bin/bash
# Dynamically sizes and repositions an invisible spacer item so that
# left-aligned workspace items flow around the MacBook notch.

DEBUG="${DEBUG:-}"

SUFFIX="$1"
FILLER="notch_filler${SUFFIX}"
LOCKFILE="/tmp/notch_filler${SUFFIX}.lock"

# Debounce: kill any previous pending run and wait for labels to settle
if [ -f "$LOCKFILE" ]; then
    prev_pid=$(cat "$LOCKFILE" 2>/dev/null)
    [ -n "$prev_pid" ] && kill "$prev_pid" 2>/dev/null
fi
echo $$ > "$LOCKFILE"
sleep 0.3
# Exit if a newer instance replaced us
[ "$(cat "$LOCKFILE" 2>/dev/null)" != "$$" ] && exit 0

# Reset filler width before measuring so it doesn't affect bounding rects
sketchybar --set "$FILLER" width=0
sleep 0.1

DISPLAY_INFO=$(sketchybar --query displays 2>/dev/null)
DISPLAY_W=$(echo "$DISPLAY_INFO" | jq '.[0].frame.w')

NOTCH_W=185
NOTCH_LEFT=$(echo "($DISPLAY_W - $NOTCH_W) / 2" | bc)
NOTCH_RIGHT=$(echo "$NOTCH_LEFT + $NOTCH_W" | bc)

[ -n "$DEBUG" ] && echo "display_width=$DISPLAY_W  notch_width=$NOTCH_W  notch_zone=$NOTCH_LEFT..$NOTCH_RIGHT"

MOVE_REF=""
MOVE_DIR=""
FILLER_W=0
LAST_VISIBLE=""
for sid in 1 2 3 4 5 6 7 8 9 10; do
    ITEM="space.${sid}${SUFFIX}"
    DATA=$(sketchybar --query "$ITEM" 2>/dev/null) || continue
    DRAWING=$(echo "$DATA" | jq -r '.geometry.drawing')
    [ "$DRAWING" = "on" ] || continue

    RECT_KEY="display-1"
    ORIGIN_X=$(echo "$DATA" | jq --arg k "$RECT_KEY" '.bounding_rects[$k].origin[0] // empty')
    SIZE_W=$(echo "$DATA" | jq --arg k "$RECT_KEY" '.bounding_rects[$k].size[0] // empty')
    [ -n "$ORIGIN_X" ] && [ -n "$SIZE_W" ] || continue

    RIGHT_EDGE=$(echo "$ORIGIN_X + $SIZE_W" | bc)
    LABEL=$(echo "$DATA" | jq -r '.label.value')

    if (( $(echo "$RIGHT_EDGE > $NOTCH_LEFT" | bc -l) )); then
        if (( $(echo "$ORIGIN_X >= $NOTCH_LEFT" | bc -l) )); then
            FILLER_W=$(echo "$NOTCH_RIGHT - $ORIGIN_X" | bc | awk '{printf "%d", $1+0.5}')
            MOVE_REF="$ITEM"
            MOVE_DIR="before"
            [ -n "$DEBUG" ] && echo "  space.$sid: x=$ORIGIN_X w=$SIZE_W right=$RIGHT_EDGE  ** STARTS IN NOTCH **  filler_w=$FILLER_W  label=\"$LABEL\""
        else
            FILLER_W=$(echo "$NOTCH_RIGHT - $RIGHT_EDGE" | bc | awk '{printf "%d", $1+0.5}')
            if (( FILLER_W < 0 )); then FILLER_W=0; fi
            MOVE_REF="$ITEM"
            MOVE_DIR="after"
            [ -n "$DEBUG" ] && echo "  space.$sid: x=$ORIGIN_X w=$SIZE_W right=$RIGHT_EDGE  ** BLEEDS INTO NOTCH **  filler_w=$FILLER_W  label=\"$LABEL\""
        fi
        break
    else
        [ -n "$DEBUG" ] && echo "  space.$sid: x=$ORIGIN_X w=$SIZE_W right=$RIGHT_EDGE <= $NOTCH_LEFT  ok  label=\"$LABEL\""
        LAST_VISIBLE="$ITEM"
    fi
done

if [ -n "$MOVE_REF" ]; then
    [ -n "$DEBUG" ] && echo "=> move $FILLER $MOVE_DIR $MOVE_REF, width=$FILLER_W"
    sketchybar --move "$FILLER" "$MOVE_DIR" "$MOVE_REF" \
               --set "$FILLER" width="$FILLER_W"
elif [ -n "$LAST_VISIBLE" ]; then
    [ -n "$DEBUG" ] && echo "=> no overlap, move after $LAST_VISIBLE, width=0"
    sketchybar --move "$FILLER" after "$LAST_VISIBLE" \
               --set "$FILLER" width=0
else
    [ -n "$DEBUG" ] && echo "=> no visible items, width=0"
    sketchybar --set "$FILLER" width=0
fi
