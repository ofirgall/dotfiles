#!/bin/bash
# Toggle "sticky" for the focused window.
# Sticky = window is sent to every workspace switch via a background watcher.
# Uses a file-based registry at $LOCALAPPDATA/komorebi-sticky/
set -e

STICKY_DIR="${LOCALAPPDATA:-$HOME/AppData/Local}/komorebi-sticky"
mkdir -p "$STICKY_DIR"

state=$(komorebic.exe state 2>/dev/null) || exit 0

# Get focused window HWND
hwnd=$(echo "$state" | python3 -c "
import sys, json
s = json.load(sys.stdin)
mon = s['monitors']['elements'][s['monitors']['focused']]
ws = mon['workspaces']['elements'][mon['workspaces']['focused']]
containers = ws.get('containers', {})
focused_idx = containers.get('focused', 0)
elements = containers.get('elements', [])
if elements:
    c = elements[focused_idx]
    wins = c.get('windows', {}).get('elements', [])
    win_idx = c.get('windows', {}).get('focused', 0)
    if wins:
        print(wins[win_idx].get('hwnd', ''))
")

if [ -z "$hwnd" ]; then
    echo "No focused window"
    exit 0
fi

sticky_file="$STICKY_DIR/$hwnd"

if [ -f "$sticky_file" ]; then
    rm "$sticky_file"
    echo "Unstickied window $hwnd"
else
    echo "$hwnd" > "$sticky_file"
    echo "Stickied window $hwnd"
fi
