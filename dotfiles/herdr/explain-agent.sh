#!/bin/bash
PANE=$(herdr pane list 2>/dev/null | jq -r '.result.panes[] | select(.focused) | .pane_id')
herdr agent explain "$PANE"
