#!/bin/bash

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
NON_EMPTY=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

IS_FOCUSED=$( [ "$1" = "$FOCUSED" ] && echo "true" || echo "false" )
HAS_WINDOWS=$(echo "$NON_EMPTY" | grep -q "^$1$" && echo "true" || echo "false")

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

if [ "$IS_FOCUSED" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        sketchybar --set "$NAME" background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT" drawing=on
    else
        sketchybar --set "$NAME" background.drawing=on icon.color=0xff1e1e1e drawing=on
    fi
elif [ "$HAS_WINDOWS" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        sketchybar --set "$NAME" background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT" drawing=on
    else
        sketchybar --set "$NAME" background.drawing=off icon.color=0xffcad3f5 drawing=on
    fi
else
    sketchybar --set "$NAME" drawing=off
fi
