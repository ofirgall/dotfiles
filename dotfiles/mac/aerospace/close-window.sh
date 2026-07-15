#!/bin/bash
# Close focused window while preventing macOS focus-stealing from switching workspace.

LOG="/tmp/aerospace-close.log"
DBG() { [ -f /tmp/aerospace-debug-enabled ] && echo "$*" >> "$LOG"; }
DBG "=== close-window.sh $(date +%H:%M:%S.%N) ==="

WS=$(aerospace list-workspaces --focused 2>/dev/null)
GROUP="${WS%%[bc]}"
MON=$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)
APP=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)

DBG "WS=$WS GROUP=$GROUP MON=$MON APP=$APP"

# Save group + monitor so revert can restore all monitors
echo "$GROUP $MON" > /tmp/aerospace-close-revert
DBG "wrote revert file: $GROUP $MON"

if [ "$APP" = "com.mitchellh.ghostty" ]; then
    DBG "closing ghostty via cmd+w"
    osascript -e 'tell application "System Events" to keystroke "w" using command down'
elif [ "$APP" = "com.lujjjh.LinearMouse" ] || [ "$APP" = "com.raycast.macos" ]; then
    DBG "closing menu bar app via cmd+w"
    osascript -e 'tell application "System Events" to keystroke "w" using command down'
else
    DBG "closing via aerospace close"
    aerospace close --quit-if-last-window 2>/dev/null
    DBG "close exit=$?"
fi

DBG "done, waiting for on-workspace-change to pick up revert"

# Backup: if no workspace-change event fires, clean up
(sleep 1 && rm -f /tmp/aerospace-close-revert && ~/dotfiles/dotfiles/mac/aerospace/on-window-detected.sh) &
