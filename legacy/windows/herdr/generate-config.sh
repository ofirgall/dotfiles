#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"            # legacy/windows/herdr: the generated files land here
CONFIG_DIR="$DIR/../../../packages/herdr/config" # the dots package's layers
PLATFORM_FILE="$CONFIG_DIR/${1:?Usage: generate-config.sh <platform> (e.g. windows, mac)}.toml"
COMMON_FILE="$CONFIG_DIR/common.toml"
OUTPUT="$DIR/config.toml"
# Dev-only overrides, merged on top of config.toml for the dev herdr (`make run`)
DEV_FILE="$CONFIG_DIR/dev.toml"
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

# Dev values at these paths replace the base instead of merging: `*+` would add
# dev rows after the common ones (so a dev layout could never change an existing
# row), and it cannot merge a dev glyph list into a common single-glyph string.
DEV_REPLACE_PATHS=(
    .ui.sidebar.spaces.rows
    .ui.sidebar.spaces.agent_rows
    .ui.sidebar.agents.rows
    .ui.status_icons.working
)

# merge_dev <base> <dev> <output>: like merge, but drops DEV_REPLACE_PATHS the
# dev file sets from the base first.
merge_dev() {
    local base="$TMPDIR/herdr-dev-base.toml"
    cp "$1" "$base"
    for path in "${DEV_REPLACE_PATHS[@]}"; do
        if [ "$(yq -p toml -o yaml "$path" "$2")" != "null" ]; then
            yq -p toml -o yaml "del($path)" "$base" > "$TMPDIR/herdr-dev-base.yaml"
            yq -p yaml -o toml '.' "$TMPDIR/herdr-dev-base.yaml" > "$base"
            rm -f "$TMPDIR/herdr-dev-base.yaml"
        fi
    done
    merge "$base" "$2" "$3"
    rm -f "$base"
}

if [ -f "$DEV_FILE" ]; then
    merge_dev "$OUTPUT" "$DEV_FILE" "$DEV_OUTPUT"
else
    rm -f "$DEV_OUTPUT"
fi
