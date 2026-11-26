#!/bin/bash
PANE=$(herdr pane list 2>/dev/null | jq -r '.result.panes[] | select(.focused) | .pane_id')
FILE=$(mktemp /tmp/herdr-read-XXXXXX)
herdr agent read "$PANE" --source detection --format ansi > "$FILE"
echo "$FILE" | pbcopy
echo "Saved to $FILE (copied to clipboard)"
