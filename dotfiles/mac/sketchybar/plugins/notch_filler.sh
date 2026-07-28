#!/bin/bash
# Dynamically sizes and repositions an invisible spacer item so that
# left-aligned workspace items flow around the MacBook notch.

DEBUG="${DEBUG:-}"

SUFFIX="$1"
FILLER="notch_filler${SUFFIX}"

sleep 0.2

# Reset filler width before measuring so it doesn't affect bounding rects
sketchybar --set "$FILLER" width=0
sleep 0.05

DISPLAY_INFO=$(sketchybar --query displays 2>/dev/null)
DISPLAY_W=$(echo "$DISPLAY_INFO" | jq '.[0].frame.w')

NOTCH_W=185
NOTCH_LEFT=$(echo "($DISPLAY_W - $NOTCH_W) / 2" | bc)
NOTCH_RIGHT=$(echo "$NOTCH_LEFT + $NOTCH_W" | bc)

[ -n "$DEBUG" ] && echo "display_width=$DISPLAY_W  notch_width=$NOTCH_W  notch_zone=$NOTCH_LEFT..$NOTCH_RIGHT"

MOVE_AFTER=""
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
        FILLER_W=$(echo "$NOTCH_RIGHT - $RIGHT_EDGE" | bc | awk '{printf "%d", $1}')
        if (( FILLER_W < 0 )); then FILLER_W=0; fi
        MOVE_AFTER="$ITEM"
        [ -n "$DEBUG" ] && echo "  space.$sid: x=$ORIGIN_X w=$SIZE_W right=$RIGHT_EDGE > $NOTCH_LEFT  ** OVERLAP **  filler_w=$FILLER_W  label=\"$LABEL\""
        break
    else
        [ -n "$DEBUG" ] && echo "  space.$sid: x=$ORIGIN_X w=$SIZE_W right=$RIGHT_EDGE <= $NOTCH_LEFT  ok  label=\"$LABEL\""
        LAST_VISIBLE="$ITEM"
    fi
done

if [ -n "$MOVE_AFTER" ]; then
    [ -n "$DEBUG" ] && echo "=> move $FILLER after $MOVE_AFTER, width=$FILLER_W"
    sketchybar --move "$FILLER" after "$MOVE_AFTER" \
               --set "$FILLER" width="$FILLER_W"
elif [ -n "$LAST_VISIBLE" ]; then
    [ -n "$DEBUG" ] && echo "=> no overlap, move after $LAST_VISIBLE, width=0"
    sketchybar --move "$FILLER" after "$LAST_VISIBLE" \
               --set "$FILLER" width=0
else
    [ -n "$DEBUG" ] && echo "=> no visible items, width=0"
    sketchybar --set "$FILLER" width=0
fi
