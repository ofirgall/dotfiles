# Herdr Configuration — Agent Guide

## Config Structure

The herdr config is a dots `render` (see `package.toml`):

```
packages/herdr/
  config/common.toml   <- shared config (edit this)
  config/mac.toml      <- macOS overrides (layer, when os = "macos")
  config/dev.toml      <- dev-herdr overrides (config-dev.generated.toml only)
  config/windows.toml  <- Windows overrides (used by generate-config.{sh,ps1}, legacy)
  scripts/ agent-detection/ herdr-256color.terminfo
~/.config/herdr/config.toml               <- RENDERED by dots (a symlink into dots state; do NOT edit)
~/.config/herdr/config-dev.generated.toml <- RENDERED (common + mac + dev)
```

`~/.config/herdr` is a real directory owned by herdr (sockets, logs, sessions, plugins);
dots links only `config.toml`, `agent-detection/` and `scripts/` into it.

## How to Edit

1. **Edit `config/common.toml`** for cross-platform settings (keybindings, UI, plugins).
2. **Edit `config/<platform>.toml`** for platform-specific overrides.
3. **Re-render** with `dots apply herdr --files-only --yes` (the `prefix+r` key does this and
   reloads herdr).
4. **Validate** with `herdr config check`.

Tables deep-merge and arrays replace (dots default), which is what the old `yq` merge
produced for these layers.

## Viewing Herdr Defaults

Print the full default config (all keys and their defaults):

```bash
herdr --default-config
```

Use `herdr config check` to validate the current config and see warnings about unknown keys.

## herdr-last-tab

A companion Rust binary in the `herdr-last-tab` package (`packages/herdr-last-tab/`). Provides "last tab" switching (like tmux `last-window`).

- **Daemon** (`herdr-last-tab daemon`): subscribes to `tab.focused` events via herdr's Unix socket, tracks previous tab per workspace in `/tmp/herdr-last-tab/`.
- **Switch** (`herdr-last-tab switch`): focuses the previously active tab. Auto-starts daemon if not running.
- Installed by dots (cargo `path = "."`).
- Started automatically by zsh hook when inside herdr (`HERDR_PANE_ID` is set).
