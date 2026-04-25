#!/bin/bash
# Usage: dim_color.sh <color> [factor]
# Takes a hex (#RRGGBB) or known color name and prints a darkened hex.
# `factor` defaults to 0.5 (50% brightness).
# Unknown names pass through unchanged (no dim applied).

input="${1:-}"
factor="${2:-0.5}"

# Resolve known names (catppuccin mocha + standard ANSI) to hex.
case "$input" in
  red)        input="#f38ba8" ;;
  green)      input="#a6e3a1" ;;
  yellow)     input="#f9e2af" ;;
  blue)       input="#89b4fa" ;;
  magenta)    input="#f5c2e7" ;;
  cyan)       input="#94e2d5" ;;
  white)      input="#cdd6f4" ;;
  black)      input="#11111b" ;;
  mauve)      input="#cba6f7" ;;
  peach)      input="#fab387" ;;
  orange)     input="#fab387" ;;
  sapphire)   input="#74c7ec" ;;
  sky)        input="#89dceb" ;;
  teal)       input="#94e2d5" ;;
  lavender)   input="#b4befe" ;;
  pink)       input="#f5c2e7" ;;
  rosewater)  input="#f5e0dc" ;;
  flamingo)   input="#f2cdcd" ;;
  maroon)     input="#eba0ac" ;;
esac

if [[ "$input" =~ ^#([0-9a-fA-F]{6})$ ]]; then
  hex="${BASH_REMATCH[1]}"
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  r=$(awk -v r=$r -v f=$factor 'BEGIN{printf "%d", r*f}')
  g=$(awk -v g=$g -v f=$factor 'BEGIN{printf "%d", g*f}')
  b=$(awk -v b=$b -v f=$factor 'BEGIN{printf "%d", b*f}')
  printf "#%02x%02x%02x\n" "$r" "$g" "$b"
else
  echo "$input"
fi
