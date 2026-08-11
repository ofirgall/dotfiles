#!/bin/bash
# Focus the next visible window in a direction, skipping hidden accordion siblings.
# Usage: focus-window.sh <left|down|up|right>

DIR=$1
SKIP=false

case "$(aerospace list-windows --focused --format '%{window-layout}')" in
    h_accordion) [[ $DIR == left || $DIR == right ]] && SKIP=true ;;
    v_accordion) [[ $DIR == up || $DIR == down ]] && SKIP=true ;;
esac

if $SKIP; then
    aerospace focus-monitor --wrap-around "$DIR"
else
    aerospace focus --boundaries all-monitors-outer-frame "$DIR"
fi

{ aerospace move-mouse window-lazy-center || aerospace move-mouse monitor-lazy-center; } &
