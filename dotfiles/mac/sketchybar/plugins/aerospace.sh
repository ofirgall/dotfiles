#!/bin/bash

# Read pre-computed state from cache (written by on-workspace-change.sh)
CACHE="/tmp/aerospace-ws-cache"
if [ -f "$CACHE" ]; then
    FOCUSED_GROUP=$(sed -n '1p' "$CACHE")
    CACHE_LINE=$(grep "^$1 " "$CACHE")
    HAS_WINDOWS=$( [ "$(echo "$CACHE_LINE" | cut -d' ' -f2)" = "1" ] && echo "true" || echo "false" )
    WIN_COUNT=$(echo "$CACHE_LINE" | cut -d' ' -f3)
else
    FOCUSED_GROUP=$(aerospace list-workspaces --focused 2>/dev/null)
    FOCUSED_GROUP="${FOCUSED_GROUP%%[bc]}"
    HAS_WINDOWS="false"
    WIN_COUNT=0
fi

IS_FOCUSED=$( [ "$1" = "$FOCUSED_GROUP" ] && echo "true" || echo "false" )
: "${WIN_COUNT:=0}"

SENTINEL="/tmp/agent-status-bg-$(id -u)"
TEMPLATE=""
AGENT_LABEL=""
AGENT_ICON=""
TMUX_SESSIONS=""
APP_ICONS=""
AGENT_BG=""
AGENT_TEXT=""

if [ -f "$SENTINEL" ]; then
    TEMPLATE=$(head -1 "$SENTINEL" | jq -r '.template // empty' 2>/dev/null)
    ws_line=$(jq -c "select(.id == $1)" "$SENTINEL" 2>/dev/null | head -1)
    if [ -n "$ws_line" ]; then
        AGENT_LABEL=$(echo "$ws_line" | jq -r '.display_name // empty')
        AGENT_ICON=$(echo "$ws_line" | jq -r '.agent_icon // empty')
        TMUX_SESSIONS=$(echo "$ws_line" | jq -r '.tmux_sessions // empty')
        APP_ICONS=$(echo "$ws_line" | jq -r '.app_icons // empty')
        if [ "$IS_FOCUSED" = "true" ]; then
            AGENT_BG=$(echo "$ws_line" | jq -r 'select(.bg_focused != "") | .bg_focused')
            AGENT_TEXT=$(echo "$ws_line" | jq -r 'select(.text_focused != "") | .text_focused')
        else
            AGENT_BG=$(echo "$ws_line" | jq -r 'select(.bg_unfocused != "") | .bg_unfocused')
            AGENT_TEXT=$(echo "$ws_line" | jq -r 'select(.text_unfocused != "") | .text_unfocused')
        fi
    fi
fi

# Build label from template or fallback
LABEL=""
if [ -n "$TEMPLATE" ] && [ -n "$AGENT_LABEL" ]; then
    LABEL="$TEMPLATE"
    LABEL="${LABEL//\{id\}/$1}"
    LABEL="${LABEL//\{agent_label\}/$AGENT_LABEL}"
    LABEL="${LABEL//\{agent_icon\}/$AGENT_ICON}"
    LABEL="${LABEL//\{tmux_sessions\}/$TMUX_SESSIONS}"
    LABEL="${LABEL//\{app_icons\}/$APP_ICONS}"
    if [ "$IS_FOCUSED" = "true" ]; then
        LABEL=$(echo "$LABEL" | sed 's/\[{window_count}\]//g; s/{window_count}//g')
    else
        LABEL=$(echo "$LABEL" | sed "s/{window_count}/$WIN_COUNT/g")
    fi
    # Collapse multiple spaces and trim
    LABEL=$(echo "$LABEL" | sed 's/  */ /g;s/^[[:space:]]*//;s/[[:space:]]*$//')
elif [ "$WIN_COUNT" -gt 1 ] 2>/dev/null; then
    LABEL="$WIN_COUNT"
fi

set_workspace() {
    if [ -n "$LABEL" ]; then
        sketchybar --set "$NAME" "label=$LABEL" label.drawing=on "$@" drawing=on
    else
        sketchybar --set "$NAME" label.drawing=off "$@" drawing=on
    fi
}

if [ "$IS_FOCUSED" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        set_workspace background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT"
    else
        set_workspace background.drawing=on icon.color=0xff1e1e1e label.color=0xff1e1e1e
    fi
elif [ "$HAS_WINDOWS" = "true" ]; then
    if [ -n "$AGENT_BG" ]; then
        set_workspace background.color="$AGENT_BG" background.drawing=on icon.color="$AGENT_TEXT" label.color="$AGENT_TEXT"
    else
        set_workspace background.drawing=off icon.color=0xffcad3f5 label.color=0xffcad3f5
    fi
else
    sketchybar --set "$NAME" label.drawing=off drawing=off
fi
