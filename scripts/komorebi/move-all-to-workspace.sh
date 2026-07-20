#!/bin/bash
# Move all windows from the focused workspace to the target workspace.
# Usage: move-all-to-workspace.sh <workspace_index_0based>
set -e

TARGET_WS="${1:?Usage: move-all-to-workspace.sh <workspace_index>}"

state=$(komorebic.exe state 2>/dev/null) || exit 0

focused_mon=$(echo "$state" | python3 -c "import sys,json; print(json.load(sys.stdin)['monitors']['focused'])")
focused_ws=$(echo "$state" | python3 -c "
import sys, json
s = json.load(sys.stdin)
mon = s['monitors']['elements'][s['monitors']['focused']]
print(mon['workspaces']['focused'])
")

# Count windows in focused workspace
win_count=$(echo "$state" | python3 -c "
import sys, json
s = json.load(sys.stdin)
mon = s['monitors']['elements'][s['monitors']['focused']]
ws = mon['workspaces']['elements'][mon['workspaces']['focused']]
count = 0
for c in ws.get('containers', {}).get('elements', []):
    count += len(c.get('windows', {}).get('elements', []))
count += len(ws.get('floating_windows', {}).get('elements', []))
mc = ws.get('monocle_container')
if mc:
    count += len(mc.get('windows', {}).get('elements', []))
print(count)
")

for ((i = 0; i < win_count; i++)); do
    komorebic.exe send-to-workspace "$TARGET_WS" 2>/dev/null || true
done

komorebic.exe focus-workspace "$TARGET_WS" 2>/dev/null || true
