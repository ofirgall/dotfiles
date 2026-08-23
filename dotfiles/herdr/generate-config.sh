#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM_FILE="$DIR/${1:?Usage: generate-config.sh <platform> (e.g. windows, mac)}-config.toml"
COMMON_FILE="$DIR/common-config.toml"
OUTPUT="$DIR/config.toml"

if [ ! -f "$PLATFORM_FILE" ]; then
    cp "$COMMON_FILE" "$OUTPUT"
    exit 0
fi

TMPDIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
yq -p toml -o yaml '.' "$COMMON_FILE" > "$TMPDIR/herdr-common.yaml"
yq -p toml -o yaml '.' "$PLATFORM_FILE" > "$TMPDIR/herdr-platform.yaml"
yq -o toml ". *+ load(\"$TMPDIR/herdr-platform.yaml\")" "$TMPDIR/herdr-common.yaml" > "$OUTPUT"
rm -f "$TMPDIR/herdr-common.yaml" "$TMPDIR/herdr-platform.yaml"
