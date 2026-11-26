#!/bin/bash
# Move ALL windows from ALL workspaces to the target workspace.
# Usage: move-all-windows-to-workspace.sh <workspace_index_0based>
set -e

TARGET_WS="${1:?Usage: move-all-windows-to-workspace.sh <workspace_index>}"

state=$(komorebic.exe state 2>/dev/null) || exit 0

focused_mon=$(echo "$state" | python3 -c "import sys,json; print(json.load(sys.stdin)['monitors']['focused'])")

# Get list of (workspace_index, window_count) for each non-target workspace
workspaces=$(echo "$state" | python3 -c "
import sys, json
s = json.load(sys.stdin)
mon = s['monitors']['elements'][s['monitors']['focused']]
target = int(sys.argv[1])
for ws_idx, ws in enumerate(mon['workspaces']['elements']):
    if ws_idx == target:
        continue
    count = 0
    for c in ws.get('containers', {}).get('elements', []):
        count += len(c.get('windows', {}).get('elements', []))
    count += len(ws.get('floating_windows', {}).get('elements', []))
    mc = ws.get('monocle_container')
    if mc:
        count += len(mc.get('windows', {}).get('elements', []))
    if count > 0:
        print(f'{ws_idx} {count}')
" "$TARGET_WS")

while IFS=' ' read -r ws_idx win_count; do
    [ -z "$ws_idx" ] && continue
    komorebic.exe focus-workspace "$ws_idx" 2>/dev/null || true
    for ((i = 0; i < win_count; i++)); do
        komorebic.exe send-to-workspace "$TARGET_WS" 2>/dev/null || true
    done
done <<< "$workspaces"

komorebic.exe focus-workspace "$TARGET_WS" 2>/dev/null || true
