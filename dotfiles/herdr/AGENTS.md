# Herdr Configuration — Agent Guide

## Config Structure

The herdr config uses a **generated config** approach:

```
dotfiles/herdr/
  common-config.toml   ← shared config (edit this)
  windows-config.toml  ← Windows-only overrides
  generate-config.sh   ← merges common + platform → config.toml
  config.toml          ← GENERATED (gitignored, do NOT edit directly)
```

## How to Edit

1. **Edit `common-config.toml`** for cross-platform settings (keybindings, UI, plugins).
2. **Edit `<platform>-config.toml`** for platform-specific overrides (e.g. `windows-config.toml` sets `default_shell`).
3. **Run `generate-config.sh <platform>`** to produce the final `config.toml`:
   ```bash
   ./dotfiles/herdr/generate-config.sh mac      # macOS
   ./dotfiles/herdr/generate-config.sh windows  # Windows
   ```
   If no platform file exists, `common-config.toml` is copied as-is.
4. **Validate** with `herdr config check`.

The merge uses `yq` deep-merge (`*+`), so platform files only need to specify overrides.

## Viewing Herdr Defaults

Print the full default config (all keys and their defaults):

```bash
herdr --default-config
```

Use `herdr config check` to validate the current config and see warnings about unknown keys.

## herdr-last-tab

A companion Rust binary at `herdr-last-tab/` in the repo root. Provides "last tab" switching (like tmux `last-window`).

- **Daemon** (`herdr-last-tab daemon`): subscribes to `tab.focused` events via herdr's Unix socket, tracks previous tab per workspace in `/tmp/herdr-last-tab/`.
- **Switch** (`herdr-last-tab switch`): focuses the previously active tab. Auto-starts daemon if not running.
- Installed via `cargo install --path herdr-last-tab`.
- Started automatically by zsh hook when inside herdr (`HERDR_PANE_ID` is set).
