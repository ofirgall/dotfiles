# macOS Migration Context

## Folder Structure

- `macos_migration/` — Tracks the migration process from Linux to macOS. Temporary — will be removed once migration is complete.
- `macREADME/` — Permanent documentation for macOS-specific setup. Survives after migration.
  - `MANUAL.md` — Manual steps (permissions, defaults commands)
  - `SYSTEM_CHANGES.md` — Native keybinds/behaviors we override
- `dotfiles/mac/` — macOS-specific config files (karabiner, etc.)
- `dotfiles/ez-workspaces-macos/` — macOS-specific app configs that diverge from Linux
- `install_scripts/mac/` — macOS install scripts
- `macos.conf.yaml` — Dotbot config for macOS symlinks and install steps
- `install-macos` — Entry point to run macOS dotbot setup

## Priorities

See the P1/P2/P3 files in this folder for migration progress tracking.
