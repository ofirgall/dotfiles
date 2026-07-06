# macOS Deviances

Tracks configs that diverge from the Linux versions due to macOS differences.

## Ghostty

- **File**: `dotfiles/ghostty/config` (shared)
- **Changes for macOS**:
  - `window-decoration = auto` (was `none` on Linux) — macOS needs window decorations for drag/fullscreen controls
  - `keybind = ctrl+shift+enter=toggle_fullscreen` — replaces WM-based fullscreen toggle

## ez-workspaces

- **File**: `dotfiles/ez-workspaces-macos/config.toml` (macOS) vs `dotfiles/ez-workspaces/config.toml` (Linux)
- **Reason**: `workspace_roots` paths differ (`/Users/ofirgal/` vs `/home/ofirg/`)
- **Config location**: `~/Library/Application Support/ez/config.toml` on macOS vs `~/.config/ez/config.toml` on Linux
- **Other differences**: None currently — keybinds, plugins, and stages are identical.
