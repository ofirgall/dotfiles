#!/bin/bash
# Dopamine music player. There is no Homebrew cask, so install the latest
# .dmg from the GitHub releases and verify it against SHA256SUMS.txt.
set -euo pipefail

APP=/Applications/Dopamine.app
REPO=digimezzo/dopamine

if [[ -d "$APP" ]]; then
    echo "Dopamine already installed"
    exit 0
fi

case "$(uname -m)" in
    arm64) ARCH=arm ;;
    *) ARCH=intel ;;
esac

TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
VERSION=${TAG#v}
DMG="Dopamine-$VERSION-$ARCH.dmg"
BASE="https://github.com/$REPO/releases/download/$TAG"

TMP=$(mktemp -d)
MOUNT=""
cleanup() {
    [[ -n "$MOUNT" ]] && hdiutil detach "$MOUNT" -quiet || true
    rm -rf "$TMP"
}
trap cleanup EXIT

echo "Downloading $DMG..."
curl -fsSL -o "$TMP/$DMG" "$BASE/$DMG"
curl -fsSL -o "$TMP/SHA256SUMS.txt" "$BASE/SHA256SUMS.txt"

EXPECTED=$(grep " $DMG\$" "$TMP/SHA256SUMS.txt" | awk '{print $1}')
ACTUAL=$(shasum -a 256 "$TMP/$DMG" | awk '{print $1}')
if [[ -z "$EXPECTED" || "$EXPECTED" != "$ACTUAL" ]]; then
    echo "Checksum mismatch for $DMG" >&2
    exit 1
fi

MOUNT=$(hdiutil attach -nobrowse -readonly "$TMP/$DMG" | grep -o '/Volumes/.*')
cp -R "$MOUNT/Dopamine.app" /Applications/
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "Dopamine $VERSION installed"
