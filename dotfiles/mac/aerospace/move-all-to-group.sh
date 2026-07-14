#!/bin/bash
# Move ALL windows from the current workspace group to target group N,
# preserving monitor assignments, then switch to the target group.
# ("Take everything with me to desk N.")

TARGET_GROUP="$1"
[ -z "$TARGET_GROUP" ] && exit 1

SUFFIXES=("" "b" "c")

CACHE="/tmp/aerospace-ws-cache"
if [ -f "$CACHE" ]; then
    CURRENT_GROUP=$(sed -n '1p' "$CACHE")
else
    CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)
    CURRENT_GROUP="${CURRENT_WS%%[bc]}"
fi

[ "$CURRENT_GROUP" = "$TARGET_GROUP" ] && exit 0

NUM_MONITORS=$(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null | wc -l | tr -d ' ')

EVAL_CMD=""
for i in $(seq 0 $((NUM_MONITORS - 1))); do
    SRC_WS="${CURRENT_GROUP}${SUFFIXES[$i]}"
    DST_WS="${TARGET_GROUP}${SUFFIXES[$i]}"

    WINDOW_IDS=$(aerospace list-windows --workspace "$SRC_WS" --format '%{window-id}' 2>/dev/null)
    for wid in $WINDOW_IDS; do
        [ -z "$wid" ] && continue
        EVAL_CMD="${EVAL_CMD}move-node-to-workspace ${DST_WS} --window-id ${wid}; "
    done
done

[ -n "$EVAL_CMD" ] && aerospace eval "$EVAL_CMD" 2>/dev/null

exec ~/dotfiles/dotfiles/mac/aerospace/switch-group.sh "$TARGET_GROUP"
