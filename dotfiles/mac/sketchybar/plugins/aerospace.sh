#!/bin/bash

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
NON_EMPTY=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

IS_FOCUSED=$( [ "$1" = "$FOCUSED" ] && echo "true" || echo "false" )
HAS_WINDOWS=$(echo "$NON_EMPTY" | grep -q "^$1$" && echo "true" || echo "false")
WIN_COUNT=$(aerospace list-windows --workspace "$1" --count 2>/dev/null)

SENTINEL="/tmp/agent-status-bg-$(id -u)"
AGENT_BG=""
AGENT_TEXT=""
if [ -f "$SENTINEL" ]; then
    line=$(grep "^$1:" "$SENTINEL" 2>/dev/null)
    if [ -n "$line" ]; then
        # Format: space_id:bg_unfocused:bg_focused:text_unfocused:text_focused
        if [ "$IS_FOCUSED" = "true" ]; then
            AGENT_BG=$(echo "$line" | cut -d: -f3)
            AGENT_TEXT=$(echo "$line" | cut -d: -f5)
        else
            AGENT_BG=$(echo "$line" | cut -d: -f2)
            AGENT_TEXT=$(echo "$line" | cut -d: -f4)
        fi
    fi
fi

LABEL_OPTS="label.drawing=off"
if [ "$WIN_COUNT" -gt 1 ] 2>/dev/null; then
    LABEL_OPTS="label=$WIN_COUNT label.drawing=on"
fi

if [ "$IS_FOCUSED" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        sketchybar --set "$NAME" background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT" $LABEL_OPTS drawing=on
    else
        sketchybar --set "$NAME" background.drawing=on icon.color=0xff1e1e1e label.color=0xff1e1e1e $LABEL_OPTS drawing=on
    fi
elif [ "$HAS_WINDOWS" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        sketchybar --set "$NAME" background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT" $LABEL_OPTS drawing=on
    else
        sketchybar --set "$NAME" background.drawing=off icon.color=0xffcad3f5 label.color=0xffcad3f5 $LABEL_OPTS drawing=on
    fi
else
    sketchybar --set "$NAME" label.drawing=off drawing=off
fi
