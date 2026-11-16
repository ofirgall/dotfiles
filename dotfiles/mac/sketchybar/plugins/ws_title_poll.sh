#!/bin/bash
# AeroSpace has no window-title event, so poll: refresh the workspace cache and
# re-render only the groups whose line changed (e.g. a Ghostty/herdr title tag).

CACHE="/tmp/aerospace-ws-cache"

poll_once() {
    local OLD NEW CHANGED_GROUPS g args
    OLD=$(cat "$CACHE" 2>/dev/null)
    "$HOME/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh"
    NEW=$(cat "$CACHE" 2>/dev/null)
    [ "$OLD" = "$NEW" ] && return
    # Focus changed: every group may need its border updated
    if [ "$(head -1 <<< "$OLD")" != "$(head -1 <<< "$NEW")" ]; then
        CHANGED_GROUPS="1 2 3 4 5 6 7 8 9 10"
    else
        CHANGED_GROUPS=$(diff <(tail -n +2 <<< "$OLD") <(tail -n +2 <<< "$NEW") | sed -n 's/^> \([0-9]*\) .*/\1/p' | sort -u)
    fi

    args=()
    for g in $CHANGED_GROUPS; do
        args+=(--trigger "aerospace_workspace_change_$g")
    done
    [ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
}

LOCK="/tmp/sketchybar-ws-poll.lock"
PENDING="/tmp/sketchybar-ws-poll.pending"

# screen_lock.sh sets this while the screen is locked
[ -f /tmp/sketchybar-screen-locked ] && exit 0

# Single flight: after unlock or a display change AeroSpace answers slowly (it re-reads
# every window title, and Chrome is slow to reply), so polls fired every 2s would queue up
# behind each other. If a poll is already running, ask it for one more pass and leave.
if ! mkdir "$LOCK" 2>/dev/null; then
    holder=$(cat "$LOCK/pid" 2>/dev/null)
    # No pid yet means the holder is between mkdir and writing it, unless the lock is old
    if { [ -n "$holder" ] && kill -0 "$holder" 2>/dev/null; } \
        || { [ -z "$holder" ] && (( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || echo 0) < 10 )); }; then
        touch "$PENDING"
        exit 0
    fi
    # Stale lock from a killed poll: take it over
    rm -rf "$LOCK"
    mkdir "$LOCK" 2>/dev/null || exit 0
fi
echo $$ > "$LOCK/pid"
trap 'rm -rf "$LOCK"' EXIT

while :; do
    rm -f "$PENDING"
    poll_once
    [ -f "$PENDING" ] || break
done
