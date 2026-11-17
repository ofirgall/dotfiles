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

# Row layouts replace instead of append: `*+` would add dev rows after the
# common ones, so a dev layout could never change an existing row.
replace_dev_rows() {
    for path in .ui.sidebar.spaces.rows .ui.sidebar.agents.rows; do
        if [ "$(yq -p toml -o yaml "$path" "$DEV_FILE")" != "null" ]; then
            yq -p toml -o yaml '.' "$DEV_OUTPUT" > "$TMPDIR/herdr-merged.yaml"
            yq -p toml -o yaml '.' "$DEV_FILE" > "$TMPDIR/herdr-dev.yaml"
            yq -o toml "$path = load(\"$TMPDIR/herdr-dev.yaml\")$path" "$TMPDIR/herdr-merged.yaml" > "$DEV_OUTPUT"
            rm -f "$TMPDIR/herdr-merged.yaml" "$TMPDIR/herdr-dev.yaml"
        fi
    done
}

if [ -f "$DEV_FILE" ]; then
    merge "$OUTPUT" "$DEV_FILE" "$DEV_OUTPUT"
    replace_dev_rows
else
    rm -f "$DEV_OUTPUT"
fi
