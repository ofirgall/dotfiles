#!/bin/bash
PANE=$(herdr pane list 2>/dev/null | jq -r '.result.panes[] | select(.focused) | .pane_id')
OUTPUT=$(herdr agent explain "$PANE")
echo "$OUTPUT"
echo "$OUTPUT" | pbcopy
