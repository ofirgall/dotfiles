# Dotfiles — Agent Guide

Cross-platform dotfiles for a vim-centric, tiling WM, terminal-first workflow. See `README.md` for user-facing docs.

## Repo Layout

```
dotfiles/              Config files symlinked into place
  mac/aerospace/       AeroSpace WM config + helper scripts
  my-zsh-conf/         Zsh aliases and overrides
  tmux_conf/           Tmux configuration
  ghostty/             Ghostty terminal config
  claude/, cursor/     AI tool configs
install_scripts/       Platform install scripts (mac/, windows/)
editors/               Neovim configs (KoalaConfig)
aerospace-scripts/     Rust binary for AeroSpace IPC (has its own AGENTS.md)
scripts/               Utility scripts (symlinked to ~/dotfiles_scripts)
agents-status/         AI agent status tool (submodule, has its own AGENTS.md)
hypr-dots/             Hyprland config (submodule)
openspec/              Specs and change tracking
```

## Key Areas

### AeroSpace (macOS window manager)

Config and scripts live in `dotfiles/mac/aerospace/`.

- `aerospace.toml` — main config: keybindings, workspace-to-monitor assignments, window rules
- `~/dotfiles/aerospace-scripts/` — Rust binary that talks to AeroSpace via Unix socket IPC (see its own `AGENTS.md`)
- `*.sh` — bash helper scripts for bindings that need logic beyond what the toml supports
- Grouped workspaces: workspaces `N`, `Nb`, `Nc` form a group; `switch-group.sh` switches all monitors together

### Keybindings

All keybindings are Linux/Hyprland-native. macOS achieves parity via Karabiner translation. See `KEYBINDINGS.md` for the full reference.

### Install Scripts

`install_scripts/mac/` contains idempotent install scripts. Each `install_*.sh` handles one tool or category. They are meant to be run independently.

## Working Rules

- Shell scripts should be bash unless POSIX sh is required.
- Config files are symlinked by dotbot (`install.conf.yaml`). Don't copy — symlink.
- AeroSpace scripts invoked via `exec-and-forget` must never block. Keep them fast.
- Performance-sensitive AeroSpace commands (focus, swap) use the Rust IPC binary. Add new commands there when multiple `aerospace` CLI calls are needed.
- `agents-status/` is a submodule with its own conventions — read its `AGENTS.md` before editing.

## Submodule Docs

- `agents-status/AGENTS.md` — agent status server, hooks, statusbar integrations
- `aerospace-scripts/AGENTS.md` — Rust AeroSpace IPC tool
