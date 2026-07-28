## Why

The repo README is severely outdated. It references tools no longer in use (AwesomeWM, alacritty, taskwarrior, Firefox/Tridactyl), contains stale TODOs, and doesn't reflect the current multi-platform setup (macOS with AeroSpace/SketchyBar, Windows with Komorebi, Linux with Hyprland). New users or future-self have no quick way to understand what this repo provides, how it's structured, or how to bootstrap a new machine.

## What Changes

- Rewrite README.md to accurately reflect the current repo: supported platforms, key tools, repo structure, and install instructions
- Remove stale TODO lists and Firefox extension docs
- Add sections for: repo structure overview, platform support matrix, submodule management (Makefile), and quick-start install per platform
- Add a visual overview of the key workflows (editor, terminal, window management)

## Capabilities

### New Capabilities

- `readme`: Repo README content, structure, and maintenance guidelines

### Modified Capabilities

- `bootstrap`: Install instructions in README must stay consistent with actual install entrypoints

## Impact

- `README.md` — full rewrite
- No code changes, no dependency changes
- `openspec/specs/bootstrap/spec.md` — may need a delta spec if README references diverge from bootstrap spec
