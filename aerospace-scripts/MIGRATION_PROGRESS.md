# Shell → Rust Migration Progress

Tracking migration of AeroSpace shell scripts to the Rust IPC binary.

## Migrated

| Script | Binding | Aerospace calls | What it does |
|---|---|---|---|
| ~~`focus-window.sh`~~ | Super+hjkl | 3 | Focus next visible window, skip accordion |
| ~~`swap-window.sh`~~ | Super+Shift+hjkl | up to 7 | Cross-monitor window swap |
| ~~`cycle-window.sh`~~ | Alt+Tab | 1 | Cycle windows in workspace |
| ~~`minimize-window.sh`~~ | Super+n | 2 | Minimize window, push to stack |
| ~~`unminimize-window.sh`~~ | Super+Shift+n | 0 (osascript only) | Restore last minimized window |
| ~~`close-window.sh`~~ | Super+q | 3 | Close window (special-cases Ghostty/menu bar apps) |
| ~~`sticky-toggle.sh`~~ | Super+p | 1 | Toggle sticky window |
| ~~`move-to-group.sh`~~ | Super+Shift+1-0 / Super+Ctrl+1-0 | 2 | Move window to group N on same monitor |
| ~~`switch-group.sh`~~ | Super+1-0 | 3 + 1 eval | Switch all monitors to workspace group N |
| ~~`switch-group-relative.sh`~~ | Super+, / Super+. | 0-1 (delegates to switch-group) | Previous/next group |
| ~~`switch-group-back.sh`~~ | Super+\` / F13 | 0 (delegates to switch-group) | Toggle back to last group |
| ~~`move-all-to-group.sh`~~ | Super+Shift+Ctrl+1-0 | 2 + 1 eval | Move all windows from current group to group N |
| ~~`move-all-windows-to-group.sh`~~ | Super+F12 | 2 + 1 eval | Move ALL windows to group 10 |

## Remaining

| Script | Binding | Aerospace calls | What it does |
|---|---|---|---|
| `tmux-viewer.sh` | Super+Shift+v | 1 | Open tmux viewer for focused session |
| `sticky-move.sh` | *(on-workspace-change)* | 2 + 0-1 eval | Move sticky windows to new workspace |
| `on-workspace-change.sh` | `exec-on-workspace-change` | 1 + 0-1 eval | Event handler: revert, sticky, cache, sketchybar |
| `move-window-to-cursor-monitor.sh` | `on-window-detected` | 2 | Move new window to cursor's monitor |

## Notes

- Scripts using `aerospace eval` already batch commands in a single IPC call — Rust benefit is eliminating the query calls before the eval.
- Scripts calling external tools (sketchybar, osascript, python) still need to shell out for those — Rust replaces the aerospace IPC portion only.
- `switch-group-relative.sh` and `switch-group-back.sh` are thin wrappers around `switch-group.sh` — migrate `switch-group` first, then fold these in as subcommands.
- `unminimize-window.sh` and `tmux-viewer.sh` are mostly osascript — minimal aerospace IPC benefit.
