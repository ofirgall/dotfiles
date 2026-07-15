#!/bin/bash

STICKY_FILE="/tmp/aerospace-sticky-windows"
touch "$STICKY_FILE"

WINDOW_ID=$(aerospace list-windows --focused --format '%{window-id}')
[ -z "$WINDOW_ID" ] && exit 0

if grep -qx "$WINDOW_ID" "$STICKY_FILE"; then
    sed -i '' "/^${WINDOW_ID}$/d" "$STICKY_FILE"
    osascript -e 'display notification "Window unstickied" with title "Aerospace"'
else
    echo "$WINDOW_ID" >> "$STICKY_FILE"
    osascript -e 'display notification "Window stickied" with title "Aerospace"'
fi
