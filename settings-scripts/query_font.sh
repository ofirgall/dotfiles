#!/usr/bin/env bash
# Usage: query_font.sh <font-file-or-dir>
# Prints font family names and styles — useful for finding the exact string to use in config files.

set -euo pipefail

target="${1:-.}"

if [[ -f "$target" ]]; then
    files=("$target")
else
    mapfile -t files < <(find "$target" -maxdepth 1 -name "*.ttf" -o -name "*.otf" | sort)
fi

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .ttf/.otf files found in: $target" >&2
    exit 1
fi

printf "%-55s %-35s %s\n" "FILE" "FAMILY" "STYLE"
printf "%-55s %-35s %s\n" "----" "------" "-----"

for f in "${files[@]}"; do
    family=$(fc-query --format="%{family}\n" "$f" 2>/dev/null | head -1)
    style=$(fc-query --format="%{style}\n" "$f" 2>/dev/null | head -1)
    printf "%-55s %-35s %s\n" "$(basename "$f")" "$family" "$style"
done
