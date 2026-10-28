#!/bin/bash
# AeroSpace has no window-title event, so poll: refresh the workspace cache and
# re-render only the groups whose line changed (e.g. a Ghostty/herdr title tag).

CACHE="/tmp/aerospace-ws-cache"

OLD=$(cat "$CACHE" 2>/dev/null)
"$HOME/dotfiles/dotfiles/mac/aerospace/update-ws-cache.sh"
NEW=$(cat "$CACHE" 2>/dev/null)
[ "$OLD" = "$NEW" ] && exit 0

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
