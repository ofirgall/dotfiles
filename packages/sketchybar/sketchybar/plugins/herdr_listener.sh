#!/bin/bash
# Refresh workspace tags as soon as herdr focuses or renames a workspace, instead of
# waiting for ws_title_poll's next tick. Started (and restarted) by sketchybarrc.

SOCK="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
POLL="$(dirname "$0")/ws_title_poll.sh"
REQ='{"id":"sketchybar","method":"events.subscribe","params":{"subscriptions":[{"type":"workspace.focused"},{"type":"workspace.renamed"}]}}'

while true; do
    # nc's stdin must stay open without writes (herdr drops the connection on blank lines),
    # so feed it from a FIFO held open read-write; the loop reconnects when nc exits.
    fifo=$(mktemp -u "${TMPDIR:-/tmp}/sketchybar-herdr-listener.XXXXXX")
    mkfifo "$fifo" && exec 3<>"$fifo" && rm -f "$fifo"
    echo "$REQ" >&3
    nc -U "$SOCK" <&3 2>/dev/null \
        | while IFS= read -r line; do
            [[ "$line" == *'"event"'* ]] || continue
            # herdr retitles the window shortly after the event
            { sleep 0.15; "$POLL"; sleep 0.35; "$POLL"; } &
        done
    exec 3>&-
    sleep 5
done
