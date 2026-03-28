#!/bin/bash
set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

echo "==> Installing gaming stack: gamescope + openbox"

# --- Openbox ---
echo "==> Installing openbox and utilities"
sudo apt install -y openbox obconf lxappearance

# --- Gamescope dependencies ---
echo "==> Installing gamescope build dependencies"
sudo apt install -y \
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
    wayland-protocols

# --- Build wayland 1.23 from source (Ubuntu 24.04 ships 1.22, wlroots needs >=1.23) ---
echo "==> Building wayland 1.23 from source"
sudo apt install -y libffi-dev libexpat1-dev
WAYLAND_DIR=/tmp/wayland-build
rm -rf "$WAYLAND_DIR"
git clone --depth 1 --branch 1.23.0 https://gitlab.freedesktop.org/wayland/wayland.git "$WAYLAND_DIR"
cd "$WAYLAND_DIR"
meson setup build --prefix=/usr/local -Ddocumentation=false -Dtests=false
ninja -C build
sudo ninja -C build install
sudo ldconfig

# --- Build gamescope from source ---
echo "==> Building gamescope from source"
GAMESCOPE_DIR=/tmp/gamescope-build

rm -rf "$GAMESCOPE_DIR"
git clone --recursive https://github.com/ValveSoftware/gamescope.git "$GAMESCOPE_DIR"

cd "$GAMESCOPE_DIR"
meson setup build \
    --prefix=/usr/local \
    --buildtype=release \
    -Dpipewire=enabled \
    -Davif_screenshots=enabled
ninja -C build
sudo ninja -C build install

echo "==> gamescope installed: $(gamescope --version 2>/dev/null || echo 'check /usr/local/bin/gamescope')"

# --- Proton GE ---
echo "==> Installing Proton GE"
bash "$CURRENT_DIR/install_proton_ge.sh"

# --- Openbox gaming config ---
echo "==> Setting up openbox gaming session config"
DOTFILES_DIR="$( cd "$CURRENT_DIR/.." && pwd )"

mkdir -p "$HOME/.config/openbox"

# Link autostart from dotfiles
if [ -f "$DOTFILES_DIR/dotfiles/openbox/autostart" ]; then
    ln -sf "$DOTFILES_DIR/dotfiles/openbox/autostart" "$HOME/.config/openbox/autostart"
fi
if [ -f "$DOTFILES_DIR/dotfiles/openbox/rc.xml" ]; then
    ln -sf "$DOTFILES_DIR/dotfiles/openbox/rc.xml" "$HOME/.config/openbox/rc.xml"
fi

echo ""
echo "==> Done! Setup summary:"
echo ""
echo "  Steam launch options for Rocket League:"
echo "    gamescope -f -w 1920 -h 1080 -r 144 --force-grab-cursor -- %command%"
echo ""
echo "  Useful gamescope flags:"
echo "    -f               fullscreen"
echo "    -b               borderless"
echo "    -w / -h          output resolution"
echo "    -r               framerate limit"
echo "    --fsr-upscaling  AMD FSR upscaling (add -W/-H for game res)"
echo "    --hdr-enabled    HDR (if display supports it)"
echo "    --mangoapp       overlay via MangoHud"
echo ""
echo "  To launch a gaming openbox session, select 'Openbox' from your display manager,"
echo "  or run: startx /usr/bin/openbox-session"
