# Dotfiles - Agent Guide

Cross-platform dotfiles for a vim-centric, tiling WM, terminal-first workflow. See `README.md` for user-facing docs.
The repo is a [dots](https://github.com/ofirgall/dots-manager) repo (`dots.toml`): `MIGRATION.md` records how it was
migrated from dotbot and what is still open.

## Repo Layout

```
dots.toml              Manifest: provider priority, tags, interim custom providers (npm-g, gh-ext, herdr-plugin, code-ext)
machines/              Profiles: mac, linux-desktop, docker, remote, windows
bundles/               Package sets (base, dev, agents, gui-apps, fonts, mac-desktop, mac-extra, work, linux-desktop, gaming, optional; windows-base/-dev/-agents/-desktop)
packages/<name>/       One package: package.toml + its config files + manual/*.md
  aerospace/           AeroSpace config and helper scripts (scripts/)
  aerospace-scripts/   Rust binary for AeroSpace IPC (has its own AGENTS.md)
  agents-status/       AI agent status tool (submodule inside, has its own AGENTS.md)
  zsh/                 zsh-conf (submodule) and my-zsh-conf
  tmux/ ghostty/ claude/ ...
lib/                   Shared shell helpers for package scripts ($DOTS_LIB: arch.sh, github-release.sh)
docs/                  mac/ system notes, keyboards/ layouts
legacy/windows/        old Windows dotbot setup, kept until the PC is cut over (README.md there); Windows packages are `when = 'os = "windows"'`
openspec/              Specs and change tracking
```

## Working with dots

- Validate with `dots lint`, preview with `dots plan`, deploy with `dots apply`, check with `dots status`
  (`make plan` / `make apply` wrap the last two). `make docker` runs the `docker` profile in an Ubuntu container.
- **Never edit generated files** in `~/.local/state/dots/gen` (rendered configs such as `~/.gitconfig`,
  `~/.config/herdr/config.toml`): edit the layer in the package (`packages/herdr/config/common.toml`,
  `packages/git/gitconfig`, ...) and re-apply. Files deployed as links (karabiner.json, settings.json, ...) are edited
  in place: the edit lands in the repo.
- Every package declares where it applies with `when` (`os = "macos"`, `gui`, `tag = "sandbox"`, ...). macOS-only
  packages are inert on Linux and Docker; anything that needs ssh, auth or private repos is `not(tag = "sandbox")`.
- Package scripts are bash with a real `check` (exit 0 = installed) and a `version`, or `versionless = true`. The runtime
  prepends `set -euo pipefail` to shell text but not to a script file: put it at the top of the file. Use `$DOTS_ARCH`,
  `$DOTS_OS` and `$DOTS_LIB`, never a hardcoded `x86_64`. Root steps use `needs_root = true` (sudo resets `HOME` and
  drops `DOTS_*`, so such a script only sees what is in its text). Hooks (`[hooks]`) are for small post-steps of a package.
- Reference deployed paths (`~/.config/aerospace/scripts/...`), never `packages/...` paths, from configs.
- Every interim construct carries a `TODO(dots-migration): ...` comment naming what replaces it.

## Key Areas

### AeroSpace (macOS window manager)

Config and scripts live in `packages/aerospace/` (deployed to `~/.aerospace.toml` and `~/.config/aerospace/scripts/`).

- `aerospace.toml` - main config: keybindings, workspace-to-monitor assignments, window rules
- `packages/aerospace-scripts/` - Rust binary that talks to AeroSpace via Unix socket IPC (see its own `AGENTS.md`)
- `scripts/on-window-detected.sh`, `scripts/refresh-workspaces.sh` - remaining bash helpers for hooks
- Grouped workspaces: workspaces `N`, `Nb`, `Nc` form a group; `aerospace-scripts switch-group` switches all monitors together

### Keybindings

All keybindings are Linux/Hyprland-native. macOS achieves parity via Karabiner translation. See `KEYBINDINGS.md` for the full reference.

## Working Rules

- Shell scripts should be bash unless POSIX sh is required.
- Config files are deployed by dots (`link` by default). Don't copy - link, unless the app rewrites the file through a symlink.
- AeroSpace scripts invoked via `exec-and-forget` must never block. Keep them fast.
- Performance-sensitive AeroSpace commands (focus, swap) use the Rust IPC binary. Add new commands there when multiple `aerospace` CLI calls are needed.
- `packages/agents-status/agents-status` is a submodule with its own conventions - read its `AGENTS.md` before editing.
- The pre-commit hook (`make init` sets `core.hooksPath`) stages the submodule pointers; no `--no-verify` is needed.

## Submodule Docs

- `packages/agents-status/agents-status/AGENTS.md` - agent status server, hooks, statusbar integrations
- `packages/aerospace-scripts/aerospace-scripts/AGENTS.md` - Rust AeroSpace IPC tool
