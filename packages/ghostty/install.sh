set -euo pipefail
# Linux source build of the latest Ghostty tag into ~/.local (build deps come from apt packages
# this package requires; dots must not run apt from a script).
source "$DOTS_LIB/arch.sh"

PREFIX="$HOME/.local"
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/ghostty-org/ghostty/tags?per_page=1" | grep -m1 '"name"' | sed -E 's/.*"([^"]+)".*/\1/')
VERSION="${LATEST_TAG#v}"
echo "Latest Ghostty version: $VERSION"

curl -fsSL "https://release.files.ghostty.org/${VERSION}/ghostty-${VERSION}.tar.gz" -o "$BUILD_DIR/ghostty.tar.gz"
tar -xf "$BUILD_DIR/ghostty.tar.gz" -C "$BUILD_DIR"
SRC_DIR=$(find "$BUILD_DIR" -mindepth 1 -maxdepth 1 -type d -name "ghostty-*" | head -1)

# The Zig version the source asks for
ZIG_VERSION=$(sed -nE 's/.*\.minimum_zig_version *= *"([^"]+)".*/\1/p' "$SRC_DIR/build.zig.zon" | head -1)
echo "Required Zig version: $ZIG_VERSION"

if [ "$(zig version 2>/dev/null || echo none)" != "$ZIG_VERSION" ]; then
	ZIG_TAR="zig-$(dots_arch zig)-linux-${ZIG_VERSION}.tar.xz"
	curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/${ZIG_TAR}" -o "$BUILD_DIR/$ZIG_TAR"
	rm -rf "$HOME/.local/zig"
	mkdir -p "$HOME/.local/zig"
	tar -xf "$BUILD_DIR/$ZIG_TAR" -C "$HOME/.local/zig" --strip-components=1
	export PATH="$HOME/.local/zig:$PATH"
fi

# gtk4-layer-shell-dev isn't packaged on Ubuntu 24.04, so always build it bundled
# (the old script fell back to this only when the package was missing).
cd "$SRC_DIR"
zig build -p "$PREFIX" -Doptimize=ReleaseFast -fno-sys=gtk4-layer-shell
"$PREFIX/bin/ghostty" --version
