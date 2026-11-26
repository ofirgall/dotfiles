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

The repo is a [dots](https://github.com/ofirgall/dots-manager) repo: packages, bundles and machine profiles. See
[MIGRATION.md](MIGRATION.md) for how it was migrated from the old dotbot layout and what is still open.

```
dots.toml           Repo manifest: provider priority, tags, interim custom providers
machines/           Machine profiles: mac, linux-desktop, docker, remote
bundles/            Named package sets (see below)
packages/<name>/    One package each: package.toml, its config files, manual/*.md
lib/                Shared shell helpers for package scripts ($DOTS_LIB)
docs/               mac/ (system notes) and keyboards/ (keyboard layouts)
legacy/windows/     Windows, still driven by dotbot (dots has no Windows support yet)
dotbot/             dotbot submodule, used only by legacy/windows
openspec/           Specs and change tracking
```

Submodules live inside their package: `packages/zsh/zsh-conf`, `packages/koala-config/KoalaConfig`,
`packages/agents-status/agents-status`, `packages/vscode/vscode-settings`, `packages/hyprland/hypr-dots`.

### Bundles

| Bundle | What |
|---|---|
| `base` | shell, git, core CLI: any box, including remote |
| `dev` | neovim/KoalaVim, tmux, language toolchains, TUIs, gh and extensions |
| `agents` | claude, codex, cursor, pi, agents-status, herdr and its plugins |
| `gui-apps` | ghostty, vscode and extensions, alacritty, spotify, browser helpers |
| `fonts` | Nerd Fonts and the terminal fonts (the Nordwand build needs about 4 GB of RAM) |
| `mac-desktop` | AeroSpace, SketchyBar, Karabiner, LinearMouse, macOS defaults and power settings |
| `mac-extra` | macOS-only brew leaves and apps (Dopamine, flameshot, ...) |
| `work` | drift.ai tools (tag `work`) |
| `linux-desktop` | Hyprland, Awesome, autolock, ACPI, xdg defaults |
| `gaming` | Steam stack (tag `gaming`): openbox, gamescope, Proton-GE; in no profile |
| `optional` | sublime, taskwarrior, firefox from the PPA, vicinae, fusuma; in no profile |

### Profiles (`machines/`)

| Profile | Bundles | Tags |
|---|---|---|
| `mac` | base dev agents gui-apps fonts mac-desktop mac-extra work | `work` |
| `linux-desktop` | base dev agents gui-apps fonts linux-desktop | add `dell` or `thinkpad` per laptop, `gaming` is opt-in |
| `docker` | base dev agents | `sandbox`; `gui = false` |
| `remote` | base | `remote` |

## Install

Install [dots](https://github.com/ofirgall/dots-manager), then bootstrap and pick a profile:

```bash
dots init --from ofirgall/dotfiles     # clone the repo (with submodules) and write machine.toml: choose a profile
dots plan                               # what would change on this machine
dots apply                              # make this machine match the repo
dots status                             # what is healthy and what needs attention
```

A machine's choice lives in `~/.config/dots/machine.toml` (`root = "~/dotfiles"` and `profile = "mac"`, or an
explicit `bundles` list). `make plan` and `make apply` are shortcuts for the last two commands.

- macOS: see [docs/mac/](docs/mac/) for tracked key conflicts and system changes. Permissions and one-time steps
  are `manual/*.md` actions of the packages (`dots status` lists the open ones).
- Linux: tags replace the old marker files. `remote` replaces `~/.remote_indicator`, `[facts] sudo = false`
  replaces `~/.no_sudo_indicator`, `sandbox` is a throwaway container with no ssh keys or private repos.
- Docker: `make docker` runs the `docker` profile in an Ubuntu 24.04 container (needs `~/workspace/personal/dots-manager`).
- Windows: see [legacy/windows/README.md](legacy/windows/README.md) (dotbot, `./legacy/windows/install-windows`).

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
make plan / make apply      # dots plan / dots apply
```

Configs are deployed by [dots](https://github.com/ofirgall/dots-manager) (`dots.toml`, `bundles/`, `packages/`);
only the Windows legacy setup still uses [Dotbot](https://github.com/anishathalye/dotbot).
