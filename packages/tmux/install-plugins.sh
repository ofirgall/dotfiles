# tpm's install_plugins without a tmux server: clone every `set -g @plugin 'owner/repo'` of plugins.tmux
set -euo pipefail
mkdir -p "$HOME/.tmux/plugins"
grep -E "^set -g @plugin '[^']+'" "$DOTS_PKG_DIR/tmux_conf/plugins.tmux" | sed -E "s/.*'(.*)'.*/\1/" | while read -r p; do
  d="$HOME/.tmux/plugins/${p##*/}"
  if [ -d "$d" ]; then continue; fi
  git clone --depth 1 "https://github.com/$p" "$d"
done
