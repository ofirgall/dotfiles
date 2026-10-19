#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM_FILE="$DIR/${1:?Usage: generate-config.sh <platform> (e.g. windows, mac)}-config.toml"
COMMON_FILE="$DIR/common-config.toml"
OUTPUT="$DIR/config.toml"
# Dev-only overrides, merged on top of config.toml for the dev herdr (`make run`)
DEV_FILE="$DIR/config-dev.toml"
DEV_OUTPUT="$DIR/config-dev.generated.toml"

TMPDIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"

# merge <base> <overlay> <output>
merge() {
    yq -p toml -o yaml '.' "$1" > "$TMPDIR/herdr-base.yaml"
    yq -p toml -o yaml '.' "$2" > "$TMPDIR/herdr-overlay.yaml"
    yq -o toml ". *+ load(\"$TMPDIR/herdr-overlay.yaml\")" "$TMPDIR/herdr-base.yaml" > "$3"
    rm -f "$TMPDIR/herdr-base.yaml" "$TMPDIR/herdr-overlay.yaml"
}

if [ -f "$PLATFORM_FILE" ]; then
    merge "$COMMON_FILE" "$PLATFORM_FILE" "$OUTPUT"
else
    cp "$COMMON_FILE" "$OUTPUT"
fi

if [ -f "$DEV_FILE" ]; then
    merge "$OUTPUT" "$DEV_FILE" "$DEV_OUTPUT"
else
    rm -f "$DEV_OUTPUT"
fi
