# Ofir's Dotfiles

Cross-platform dotfiles for a vim-centric, tiling WM, terminal-first workflow.

## Workflow

- **One task = one workspace** — [ez-workspaces](https://github.com/KoalaVim/ez-workspaces) spins up a tmux session + git worktree per feature
- **Browser + terminal per workspace** — each workspace holds a browser and a terminal attached to its tmux session
- **Statusbar = full visibility** — [agents-status](https://github.com/KoalaVim/agents-status) shows every session's name and state (active, idle, waiting) at a glance

## Platforms

| | Window Manager | Terminal | Status Bar | Key Remapper |
|---|---|---|---|---|
| **macOS** | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | [Ghostty](https://ghostty.org) | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | [Karabiner-Elements](https://karabiner-elements.pqrs.org) |
| **Linux** | [Hyprland](https://hyprland.org) | [Ghostty](https://ghostty.org) | [Waybar](https://github.com/Alexays/Waybar) | — |
| **Windows** | [Komorebi](https://github.com/LGUG2Z/komorebi) | [Ghostty](https://ghostty.org) / [WezTerm](https://wezfurlong.org/wezterm/) | [Yasb](https://github.com/da-rth/yasb) | [Kanata](https://github.com/jtroo/kanata) |

### KoalaVim Tools

Several tools from the [KoalaVim](https://github.com/KoalaVim) org are used across platforms:

- [KoalaVim](https://github.com/KoalaVim/KoalaVim) — Neovim distribution
- [kv](https://github.com/KoalaVim/kv.git) — KoalaVim CLI launcher
- [zsh-conf](https://github.com/ofirgall/zsh-conf) — Zsh configuration framework
- [agents-status](https://github.com/KoalaVim/agents-status) — AI agent session status, notifications, and statusbar integration
- [ez-workspaces](https://github.com/KoalaVim/ez-workspaces) — Session + worktree manager per task/feature

## Keybindings

All keybindings are Linux/Hyprland-native — macOS achieves parity via a Karabiner translation layer. See [KEYBINDINGS.md](KEYBINDINGS.md) for the full binding reference.

## Repo Structure

```
dotfiles/           Config files (tmux, zsh, ghostty, mac/, windows/, ...)
install_scripts/    Platform install scripts (common/, mac/, windows/)
editors/            Editor configs (KoalaConfig for Neovim)
agents-status/      AI agent status tool (submodule)
scripts/            Utility scripts (symlinked to ~/dotfiles_scripts)
openspec/           Specs and change tracking
macREADME/          macOS-specific docs and post-install manual steps
winREADME/          Windows-specific docs and post-install manual steps
hypr-dots/          Hyprland config (submodule)
```

## Install

### macOS

```bash
git clone --recurse-submodules git@github.com:ofirgall/dotfiles.git
cd dotfiles && make init && ./install-macos
```

See [macREADME/MANUAL.md](macREADME/MANUAL.md) for post-install manual steps (permissions, one-time setup).

### Linux (Ubuntu)

```bash
git clone --recurse-submodules git@github.com:ofirgall/dotfiles.git
cd dotfiles && make init && ./install
```

Optional flags before running install:
- `touch ~/.remote_indicator` — skip local (Linux-specific) config, run common only
- `touch ~/.no_sudo_indicator` — skip commands requiring sudo

### Windows

```bash
git clone --recurse-submodules git@github.com:ofirgall/dotfiles.git
cd dotfiles && make init && ./install-windows
```

See [winREADME/MANUAL.md](winREADME/MANUAL.md) for post-install manual steps.

## Git Setup

Create `~/.git_user` with your identity:

```gitconfig
[user]
    name = "Your Name"
    email = "you@example.com"
```

For work repos, create `~/.git_work`:

```gitconfig
[user]
    name = "Your Name"
    email = "you@work.com"
[core]
    sshCommand = ssh -i ~/.ssh/<work ssh key>
```

## Submodule Management

Submodules are managed via the [Makefile](Makefile):

```bash
make init      # Initialize submodules + configure git hooks
make update    # Pull all submodules to latest (aborts if any is dirty)
make status    # Show submodule states
make add REPO=<url>         # Add a new submodule
make remove NAME=<path>     # Remove a submodule
make foreach CMD='<cmd>'    # Run a command in each submodule
```

Orchestrated by [Dotbot](https://github.com/anishathalye/dotbot) — install configs are layered via YAML files (`common.conf.yaml`, `macos.conf.yaml`, `windows.conf.yaml`, `install.conf.yaml`).
