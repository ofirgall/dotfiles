#!/bin/bash
# Collie (herdr mobile client) reachable only over the tailnet.
#
# Collie binds loopback and publishes itself with `tailscale serve` (HTTPS on :443). The tailnet
# policy decides which devices can reach this Mac, and Collie's device pairing gates each device.
#
# COLLIE_TRUSTED_USER stays unset: serve sends no identity header for tagged devices, so setting it
# would lock out a tagged phone.
#
# COLLIE_SERVE_PORT is not the default 443 because colima's traefik forward holds *:443 on this Mac.
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

COLLIE_PORT=8787
COLLIE_SERVE_PORT=8443

if ! command -v tailscale &>/dev/null; then
    echo "tailscale CLI not on PATH: install it from the Tailscale app settings" >&2
    exit 1
fi

if ! tailscale status --json | grep -q '"CertDomains": *\['; then
    echo "tailscale serve needs HTTPS certificates: enable them at https://login.tailscale.com/admin/dns" >&2
    exit 1
fi

if ! herdr plugin list 2>/dev/null | grep -q herdr.collie; then
    herdr plugin install AltanS/collie --yes
fi

CONFIG_DIR="$(herdr plugin config-dir herdr.collie)"
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/.env" ]; then
    cat >"$CONFIG_DIR/.env" <<EOF
COLLIE_MUX=herdr
COLLIE_PORT=$COLLIE_PORT
COLLIE_SERVE_PORT=$COLLIE_SERVE_PORT
EOF
fi

# Start alone would not load new keys into a running bridge.
START_ACTION=start
if ! grep -q '^COLLIE_VAPID_PUBLIC=' "$CONFIG_DIR/.env"; then
    "$HOME/dotfiles_scripts/misc/collie" push-keys
    START_ACTION=restart
fi

herdr plugin action invoke "$START_ACTION" --plugin herdr.collie
