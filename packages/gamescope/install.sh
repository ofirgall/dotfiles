# Gamescope from source (Ubuntu 24.04 lacks it). Wayland 1.23 is built first (wlroots needs it).
set -euo pipefail
apt-get install -y \
	git cmake meson ninja-build pkg-config \
	libwayland-dev libwayland-egl-backend-dev \
	libxcb1-dev libxcb-icccm4-dev libxcb-util-dev \
	libxcb-ewmh-dev libxcb-composite0-dev libxcb-res0-dev \
	libxcb-xf86dri0-dev libxcb-dri3-dev libxcb-present-dev \
	libxcb-xinput-dev libxcb-render-util0-dev libxcb-image0-dev \
	libxcb-keysyms1-dev libxcb-xtest0-dev libxcb-cursor-dev \
	libx11-dev libx11-xcb-dev libxcomposite-dev libxrender-dev libxfixes-dev libxxf86vm-dev libxres-dev libxmu-dev \
	libxkbcommon-dev libxkbcommon-x11-dev \
	libdrm-dev libgbm-dev libegl-dev libgl-dev \
	libvulkan-dev vulkan-tools glslang-tools spirv-tools \
	libpipewire-0.3-dev libseat-dev \
	libcap-dev libavif-dev \
	libdisplay-info-dev libliftoff-dev libdecor-0-dev \
	libluajit-5.1-dev libeis-dev libinput-dev libudev-dev \
	libpixman-1-dev libsdl2-dev libxi-dev \
	wayland-protocols libffi-dev libexpat1-dev

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

echo "==> Building wayland 1.23 from source"
git clone --depth 1 --branch 1.23.0 https://gitlab.freedesktop.org/wayland/wayland.git "$tmp/wayland"
(cd "$tmp/wayland" && meson setup build --prefix=/usr/local -Ddocumentation=false -Dtests=false && ninja -C build && ninja -C build install)
ldconfig

echo "==> Building gamescope from source"
git clone --recursive https://github.com/ValveSoftware/gamescope.git "$tmp/gamescope"
cd "$tmp/gamescope"
meson setup build --prefix=/usr/local --buildtype=release -Dpipewire=enabled -Davif_screenshots=enabled
ninja -C build
ninja -C build install
