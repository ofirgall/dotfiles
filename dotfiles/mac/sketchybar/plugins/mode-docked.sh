#!/bin/bash
# Switch sketchybar to docked mode (external displays connected)
rm -f /tmp/sketchybar-display-info
"$(dirname "$0")/detect_displays.sh"
sketchybar --reload
