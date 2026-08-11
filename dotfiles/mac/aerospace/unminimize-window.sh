#!/bin/bash
# Un-minimize the most recently minimized window by popping from the stack.

STACK="/tmp/aerospace-minimized-stack"
LOG="/tmp/aerospace-unminimize.log"
DBG() { echo "$*" >> "$LOG"; }

[ ! -s "$STACK" ] && { DBG "stack empty"; exit 0; }

LAST=$(tail -1 "$STACK")
APP_NAME=$(echo "$LAST" | cut -d'|' -f2)
WINDOW_TITLE=$(echo "$LAST" | cut -d'|' -f3-)

DBG "=== unminimize $(date +%H:%M:%S) ==="
DBG "app=$APP_NAME title=$WINDOW_TITLE"

sed -i '' '$d' "$STACK"

osascript <<'APPLESCRIPT' - "$APP_NAME" "$WINDOW_TITLE" 2>>"$LOG"
on run argv
    set appName to item 1 of argv
    set winTitle to item 2 of argv

    tell application "System Events"
        tell process appName
            set didRestore to false
            -- Try to match by title first
            repeat with w in every window
                if value of attribute "AXMinimized" of w is true then
                    if value of attribute "AXTitle" of w is winTitle then
                        set value of attribute "AXMinimized" of w to false
                        set didRestore to true
                        exit repeat
                    end if
                end if
            end repeat
            -- Fallback: restore first minimized window
            if not didRestore then
                repeat with w in every window
                    if value of attribute "AXMinimized" of w is true then
                        set value of attribute "AXMinimized" of w to false
                        exit repeat
                    end if
                end repeat
            end if
        end tell
    end tell

    tell application appName to activate
end run
APPLESCRIPT
DBG "exit=$?"
