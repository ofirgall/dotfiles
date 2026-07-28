# Keybinding Philosophy

All keybindings are **Linux/Hyprland-native** — macOS achieves parity via a Karabiner translation layer. The goal is identical muscle memory across all platforms.

## Layers

- **Super** — Window management (WM-level)
- **Alt** — Terminal / tmux / nvim pane navigation
- **Ctrl** — Standard GUI shortcuts (copy, paste, etc.)

## Window Management (Super)

| Binding | Action |
|---|---|
| Super+hjkl | Focus window (crosses monitors) |
| Super+Shift+hjkl | Swap window |
| Super+Alt+hjkl | Move window (non-swap) |
| Super+Ctrl+hjkl | Resize window |
| Super+1-9, 0 | Switch workspace group |
| Super+Shift+1-9, 0 | Move window to workspace (follow) |
| Super+Ctrl+1-9, 0 | Move window to workspace (silent) |
| Super+q | Close window |
| Super+m | Maximize / accordion toggle |
| Super+n | Minimize / hide window |
| Super+o | Move window to next monitor |
| Super+/ | Layout toggle (horizontal / vertical) |
| Super+Shift+f | Float toggle |
| Super+p | Sticky window toggle |
| Super+, / Super+. | Previous / next workspace |
| Super+\` | Last workspace |
| Super+Enter | Open terminal |
| Super+b | Open browser |
| Super+r | App launcher (Raycast on macOS) |
| Super+s | Screenshot region to clipboard |
| Super+Shift+s | Screenshot UI toolbar to clipboard |
| Super+Space | Toggle input language |
| Super+Shift+r | Reload WM + statusbar config |
| Alt+Tab | Cycle windows in workspace |
| Alt+v | Clipboard history |

## Terminal / Tmux (Alt)

| Binding | Action |
|---|---|
| Alt+e | Split horizontal (nvim or tmux) |
| Alt+o | Split vertical (nvim or tmux) |
| Alt+w / Alt+q | Close pane (nvim or tmux) |
| Alt+hjkl | Navigate panes (nvim or tmux) |
| Alt+Shift+{e,o,w} | Force tmux action (bypass nvim) |

## System (Ctrl)

| Binding | Action |
|---|---|
| Ctrl+c/v/x/z/a/f/w/t/n/l/k | Standard GUI shortcuts |
| Ctrl+Shift+c/v | Terminal copy/paste |
| CapsLock | Escape |

## macOS Translation

On macOS, [Karabiner-Elements](https://karabiner-elements.pqrs.org) remaps keys to match the Linux-native bindings:

- **Ctrl to Cmd in GUI apps** — Left Ctrl + {c,v,x,z,a,f,...} remaps to Cmd in non-terminal apps
- **Terminal passthrough** — Ctrl is not remapped in Ghostty/Terminal so Ctrl+C sends SIGINT
- **Cmd to F-keys** — Cmd+k/l remap to F15/F16 so AeroSpace receives them before macOS intercepts
- **Built-in keyboard normalization** — Fn↔Left Ctrl and Left Cmd↔Left Option swapped to match PC layout (built-in keyboard only)

See [macREADME/KEY_CONFLICTS.md](macREADME/KEY_CONFLICTS.md) for tracked conflicts between dotfiles bindings and native macOS shortcuts.
