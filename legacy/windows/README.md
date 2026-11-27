# Windows (legacy, dotbot)

Migrated to dots packages (`machines/windows.toml`, `windows-*` bundles; see `MIGRATION.md`, "Windows migration"). This directory
is still what the PC runs until cutover, then it is deleted.

dots has no Windows support yet, so Windows keeps using the `dotbot` submodule. Everything else in
this repo (`packages/`, `bundles/`, `machines/`) is dots only.

## Run

From PowerShell: `.\legacy\windows\install-windows.ps1` (checks symlinks, installs Git and Python, then
runs dotbot). From Git Bash: `legacy/windows/install-windows`. Both run
`dotbot -d <repo root> -c legacy/windows/windows.conf.yaml`, so every path in `windows.conf.yaml` is
relative to the repo root.

## Layout

| Path | What |
|---|---|
| `windows.conf.yaml` | the dotbot config; links point at the shared `packages/<pkg>/...` files |
| `install_scripts/` | the Windows installers (was `install_scripts/windows/`) |
| `pwsh-conf/`, `my-pwsh-conf/` | PowerShell profile and aliases |
| `apps/` | komorebi, flow-launcher, kanata, yasb configs (was `dotfiles/windows/`) |
| `setup/` | AutoHotkey startup, `.wezterm.lua`, registry tweaks (was top-level `windows/`) |
| `ghostty/` | `config.windows` and `config-winghostty` |
| `herdr/` | `generate-config.{sh,ps1}`: merge `packages/herdr/config/{common,windows}.toml` into `herdr/config.toml` |
| `gitconfig` | snapshot of the pre-dots monolithic gitconfig (the dots one is composed from fragments) |
| `agents-status-config-windows.toml`, `ez-workspaces/` | Windows variants of two package configs |
| `winREADME/` | manual steps |

Nothing here was exercised during the dots migration: the paths were rewritten by hand.
