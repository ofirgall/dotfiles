# Collie binds loopback and publishes itself with `tailscale serve`. COLLIE_TRUSTED_USER stays
# unset (serve sends no identity header for tagged devices). COLLIE_SERVE_PORT is 8443 because
# colima's traefik forward holds *:443 on this Mac.
set -euo pipefail
# The CLI is the app's own binary (my-zsh-conf aliases it; scripts don't see aliases).
TAILSCALE="$(command -v tailscale || echo /Applications/Tailscale.app/Contents/MacOS/Tailscale)"
if [ ! -x "$TAILSCALE" ]; then
  echo "Tailscale not found (install the Tailscale app): see herdr-collie/manual/tailscale.md" >&2; exit 1
fi
# Capture before grepping: under pipefail, `cmd | grep -q` fails when grep exits at the first
# match and cmd dies of SIGPIPE writing the rest.
if ! grep -q '"CertDomains": *\[' <<<"$("$TAILSCALE" status --json)"; then
  echo "tailscale serve needs HTTPS certificates: enable them at https://login.tailscale.com/admin/dns" >&2; exit 1
fi
# Before any change: the push keys mark this setup done, so it must not get that far without a
# server to start the bridge on (manual action herdr-collie/herdr-running).
if ! grep -q '^status: running' <<<"$(herdr status server 2>/dev/null || true)"; then
  echo "herdr is not running: start it (run \`herdr\`), then dots apply herdr-collie-setup" >&2; exit 1
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
herdr plugin action invoke "$START_ACTION" --plugin herdr.collie
