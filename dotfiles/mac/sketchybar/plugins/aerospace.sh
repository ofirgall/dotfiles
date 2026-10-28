#!/bin/bash
# Render one workspace: number as icon, app icons as label, Chrome profile tags in a
# separate item (own font). The pill background lives on the bracket around both.
# Reads /tmp/aerospace-ws-cache written by aerospace/update-ws-cache.sh.
# Usage: aerospace.sh <group> [display]  (display 0 or omitted = all screens)

BG=0xff23243e
FOCUSED_BORDER=0xffcba6f7
FOCUSED_TEXT=0xffc2b0d9
UNFOCUSED_TEXT=0xffa287c5
BORDER_WIDTH=2
# Gap between the app icons and the tags
TAG_GAP=6

DISPLAY_ID="${2:-0}"
SUFFIX="${NAME#space.$1}"
TAGS_ITEM="space.$1.tags$SUFFIX"
GAP_ITEM="space_gap.$1$SUFFIX"
BRACKET="space_bracket.$1$SUFFIX"

CACHE="/tmp/aerospace-ws-cache"
if [ -f "$CACHE" ]; then
    FOCUSED_GROUP=$(sed -n '1p' "$CACHE")
    CACHE_LINE=$(grep "^$1 $DISPLAY_ID " "$CACHE")
    # Fall back to the all-screens line if this display isn't in the cache yet
    [ -n "$CACHE_LINE" ] || CACHE_LINE=$(grep "^$1 0 " "$CACHE")
    read -r _ _ HAS_WINDOWS _ ENTRIES <<< "$CACHE_LINE"
    APP_ICONS="${ENTRIES%%|*}"
    [[ "$ENTRIES" == *"|"* ]] && TAGS="${ENTRIES#*|}"
else
    FOCUSED_GROUP=$(aerospace list-workspaces --focused 2>/dev/null)
    FOCUSED_GROUP="${FOCUSED_GROUP%%[bc]}"
fi

if [ "$1" = "$FOCUSED_GROUP" ]; then
    TEXT=$FOCUSED_TEXT; BORDER=$BORDER_WIDTH
elif [ "$HAS_WINDOWS" = "1" ]; then
    TEXT=$UNFOCUSED_TEXT; BORDER=0
else
    sketchybar --set "$NAME" drawing=off \
               --set "$TAGS_ITEM" drawing=off \
               --set "$GAP_ITEM" drawing=off \
               --set "$BRACKET" background.drawing=off
    exit 0
fi

if [ -n "$APP_ICONS" ]; then
    LABEL_PROPS=("label=$APP_ICONS" label.drawing=on)
else
    LABEL_PROPS=(label.drawing=off)
fi

# With tags, the tags item carries the pill's right inner padding
if [ -n "$TAGS" ]; then
    LABEL_PROPS+=(label.padding_right="$TAG_GAP")
    TAG_PROPS=(drawing=on "label=$TAGS" label.color="$TEXT")
else
    LABEL_PROPS+=(label.padding_right=8)
    TAG_PROPS=(drawing=off)
fi

sketchybar --set "$NAME" drawing=on "${LABEL_PROPS[@]}" \
               icon.color="$TEXT" label.color="$TEXT" \
           --set "$TAGS_ITEM" "${TAG_PROPS[@]}" \
           --set "$GAP_ITEM" drawing=on \
           --set "$BRACKET" \
               background.color="$BG" background.drawing=on \
               background.border_color="$FOCUSED_BORDER" background.border_width="$BORDER"
