# Collie binds loopback and publishes itself with `tailscale serve`. COLLIE_TRUSTED_USER stays
# unset (serve sends no identity header for tagged devices). COLLIE_SERVE_PORT is 8443 because
# colima's traefik forward holds *:443 on this Mac.
set -euo pipefail
if ! command -v tailscale >/dev/null; then
  echo "tailscale CLI not on PATH: see manual/tailscale.md" >&2; exit 1
fi
if ! tailscale status --json | grep -q '"CertDomains": *\['; then
  echo "tailscale serve needs HTTPS certificates: enable them at https://login.tailscale.com/admin/dns" >&2; exit 1
fi
CONFIG_DIR="$(herdr plugin config-dir herdr.collie)"
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/.env" ]; then
  cat >"$CONFIG_DIR/.env" <<EOF
COLLIE_MUX=herdr
COLLIE_PORT=8787
COLLIE_SERVE_PORT=8443
EOF
fi
# start alone would not load new keys into a running bridge
START_ACTION=start
if ! grep -q '^COLLIE_VAPID_PUBLIC=' "$CONFIG_DIR/.env"; then
  "$HOME/dotfiles_scripts/misc/collie" push-keys
  START_ACTION=restart
fi
herdr plugin action invoke "$START_ACTION" --plugin herdr.collie || true
