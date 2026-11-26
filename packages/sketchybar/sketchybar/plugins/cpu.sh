#!/bin/bash

CPU=$(ps -A -o %cpu | awk -v cores="$(sysctl -n hw.logicalcpu)" 'NR>1{s+=$1} END {printf "%.0f", s/cores}')
sketchybar --set "$NAME" label="${CPU}%"
