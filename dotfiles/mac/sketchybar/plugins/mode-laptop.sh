#!/bin/bash
# Switch sketchybar to laptop mode (built-in display only)
rm -f /tmp/sketchybar-display-info
"$(dirname "$0")/detect_displays.sh"
sketchybar --reload
