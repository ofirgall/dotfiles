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
[ "$(cat "$LOCKFILE" 2>/dev/null)" != "$$" ] && exit 0

DISPLAY_INFO=$(sketchybar --query displays 2>/dev/null)
DISPLAY_W=$(echo "$DISPLAY_INFO" | jq '.[0].frame.w')

NOTCH_W=185
NOTCH_LEFT=$(echo "($DISPLAY_W - $NOTCH_W) / 2" | bc)
NOTCH_RIGHT=$(echo "$NOTCH_LEFT + $NOTCH_W" | bc)

# Get current filler width and position in item order to compensate
# without resetting (which causes flicker)
FILLER_DATA=$(sketchybar --query "$FILLER" 2>/dev/null)
CUR_FILLER_W=$(echo "$FILLER_DATA" | jq '.geometry.width // 0')
[ "$CUR_FILLER_W" = "-1" ] && CUR_FILLER_W=0

BAR_ITEMS=$(sketchybar --query bar 2>/dev/null | jq -r '.items[]')
FILLER_IDX=-1
idx=0
while IFS= read -r item_name; do
    if [ "$item_name" = "$FILLER" ]; then
        FILLER_IDX=$idx
        break
    fi
    idx=$((idx + 1))
done <<< "$BAR_ITEMS"

[ -n "$DEBUG" ] && echo "display_width=$DISPLAY_W  notch_zone=$NOTCH_LEFT..$NOTCH_RIGHT  cur_filler_w=$CUR_FILLER_W  filler_idx=$FILLER_IDX"

MOVE_REF=""
MOVE_DIR=""
FILLER_W=0
LAST_VISIBLE=""
ITEM_IDX=0
for sid in 1 2 3 4 5 6 7 8 9 10; do
    ITEM="space.${sid}${SUFFIX}"
    DATA=$(sketchybar --query "$ITEM" 2>/dev/null) || continue
    DRAWING=$(echo "$DATA" | jq -r '.geometry.drawing')
    [ "$DRAWING" = "on" ] || continue

    RECT_KEY="display-1"
    ORIGIN_X=$(echo "$DATA" | jq --arg k "$RECT_KEY" '.bounding_rects[$k].origin[0] // empty')
    SIZE_W=$(echo "$DATA" | jq --arg k "$RECT_KEY" '.bounding_rects[$k].size[0] // empty')
    [ -n "$ORIGIN_X" ] && [ -n "$SIZE_W" ] || continue

    # Compensate: items after the filler are shifted right by the current filler width
    NATURAL_X="$ORIGIN_X"
    NATURAL_RIGHT=$(echo "$ORIGIN_X + $SIZE_W" | bc)
    if (( FILLER_IDX >= 0 && ITEM_IDX >= FILLER_IDX )) && (( CUR_FILLER_W > 0 )); then
        NATURAL_X=$(echo "$ORIGIN_X - $CUR_FILLER_W" | bc)
        NATURAL_RIGHT=$(echo "$NATURAL_X + $SIZE_W" | bc)
    fi
    ITEM_IDX=$((ITEM_IDX + 1))

    LABEL=$(echo "$DATA" | jq -r '.label.value')

    if (( $(echo "$NATURAL_RIGHT > $NOTCH_LEFT" | bc -l) )); then
        if (( $(echo "$NATURAL_X >= $NOTCH_LEFT" | bc -l) )); then
            FILLER_W=$(echo "$NOTCH_RIGHT - $NATURAL_X" | bc | awk '{printf "%d", $1+0.5}')
            MOVE_REF="$ITEM"
            MOVE_DIR="before"
            [ -n "$DEBUG" ] && echo "  space.$sid: natural_x=$NATURAL_X w=$SIZE_W natural_right=$NATURAL_RIGHT  ** STARTS IN NOTCH **  filler_w=$FILLER_W  label=\"$LABEL\""
        else
            FILLER_W=$(echo "$NOTCH_RIGHT - $NATURAL_RIGHT" | bc | awk '{printf "%d", $1+0.5}')
            if (( FILLER_W < 0 )); then FILLER_W=0; fi
            MOVE_REF="$ITEM"
            MOVE_DIR="after"
            [ -n "$DEBUG" ] && echo "  space.$sid: natural_x=$NATURAL_X w=$SIZE_W natural_right=$NATURAL_RIGHT  ** BLEEDS INTO NOTCH **  filler_w=$FILLER_W  label=\"$LABEL\""
        fi
        break
    else
        [ -n "$DEBUG" ] && echo "  space.$sid: natural_x=$NATURAL_X w=$SIZE_W natural_right=$NATURAL_RIGHT <= $NOTCH_LEFT  ok  label=\"$LABEL\""
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
