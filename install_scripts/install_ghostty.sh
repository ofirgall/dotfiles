#!/bin/bash

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

INSTALL_PREFIX="${GHOSTTY_PREFIX:-$HOME/.local}"
BUILD_DIR="/tmp/ghostty-build"

# Fetch latest tag from GitHub
LATEST_TAG=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/tags?per_page=1 | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['name'])")
VERSION="${LATEST_TAG#v}"
echo "Latest Ghostty version: $VERSION"

# Download source tarball (preferred over git checkout per Ghostty docs)
TARBALL_URL="https://release.files.ghostty.org/${VERSION}/ghostty-${VERSION}.tar.gz"
echo "Downloading source tarball from $TARBALL_URL..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
wget -q "$TARBALL_URL" -O "$BUILD_DIR/ghostty-${VERSION}.tar.gz"
tar -xf "$BUILD_DIR/ghostty-${VERSION}.tar.gz" -C "$BUILD_DIR"

SRC_DIR=$(find "$BUILD_DIR" -mindepth 1 -maxdepth 1 -type d -name "ghostty-*" | head -1)

# Determine required Zig version from the source
ZIG_VERSION=$(python3 -c "
import re, pathlib
zon = pathlib.Path('$SRC_DIR/build.zig.zon').read_text()
print(re.search(r'\.minimum_zig_version\s*=\s*\"([^\"]+)\"', zon).group(1))
")
echo "Required Zig version: $ZIG_VERSION"

# Install Zig if needed
CURRENT_ZIG_VERSION=$(zig version 2>/dev/null || echo "none")
if [ "$CURRENT_ZIG_VERSION" != "$ZIG_VERSION" ]; then
	echo "Installing Zig $ZIG_VERSION..."
	ZIG_TAR="zig-x86_64-linux-${ZIG_VERSION}.tar.xz"
	ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/${ZIG_TAR}"
	wget -q "$ZIG_URL" -O "/tmp/${ZIG_TAR}"
	rm -rf "$HOME/.local/zig"
	mkdir -p "$HOME/.local/zig"
	tar -xf "/tmp/${ZIG_TAR}" -C "$HOME/.local/zig" --strip-components=1
	rm "/tmp/${ZIG_TAR}"
	export PATH="$HOME/.local/zig:$PATH"
	echo "Zig $(zig version) installed"
else
	echo "Zig $ZIG_VERSION already installed"
fi

# Install build dependencies
echo "Installing build dependencies..."
sudo apt install -y \
	libgtk-4-dev \
	libadwaita-1-dev \
	gettext \
	libxml2-utils

BUILD_FLAGS="-p $INSTALL_PREFIX -Doptimize=ReleaseFast"

# gtk4-layer-shell-dev isn't packaged on some distros (e.g. Ubuntu 24.04)
if ! apt list --installed libgtk4-layer-shell-dev 2>/dev/null | grep -q installed; then
	echo "gtk4-layer-shell-dev not available, building from source..."
	BUILD_FLAGS="$BUILD_FLAGS -fno-sys=gtk4-layer-shell"
else
	sudo apt install -y libgtk4-layer-shell-dev
fi

# Build and install
echo "Building Ghostty $VERSION..."
cd "$SRC_DIR"
zig build $BUILD_FLAGS

# Cleanup
rm -rf "$BUILD_DIR"

echo "Ghostty $VERSION installed to $INSTALL_PREFIX"
"$INSTALL_PREFIX/bin/ghostty" --version
