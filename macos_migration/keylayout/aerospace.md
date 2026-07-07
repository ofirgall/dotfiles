# Aerospace WM Keybinds

Binds to **Cmd** modifier (which is physically in the Super/Option position after the Karabiner swap).

## Keybind Mapping from AwesomeWM/Hyprland

| Linux | Aerospace | Action |
|---|---|---|
| Super+hjkl | cmd+hjkl | Focus direction |
| Super+Shift+hjkl | cmd+shift+hjkl | Swap windows |
| Super+1-9 | cmd+1-9 | Switch workspace |
| Super+Shift+1-9 | cmd+shift+1-9 | Move window to workspace |
| Super+Enter | cmd+enter | Open terminal |
| Super+q | cmd+q | Close window |
| Super+f | cmd+f | Toggle fullscreen |
| Super+m / Super+z | cmd+m / cmd+z | Toggle maximize |
| Super+, / Super+. | cmd+, / cmd+. | Prev/next workspace |
| Super+\` | cmd+\` | Last workspace |
| Super+o | cmd+o | Move to other monitor |
| Alt+Tab | alt+tab | Cycle windows |
| Super+Space | cmd+space | Language switch (see open decisions) |

## macOS System Shortcut Conflicts

These native macOS shortcuts conflict with our Aerospace bindings. Each must be either intercepted by Aerospace or disabled in System Settings.

| Shortcut | macOS Default | Our Use | Resolution |
|---|---|---|---|
| Cmd+H | Hide window | Focus left | Aerospace intercepts / disable in System Settings |
| Cmd+M | Minimize window | Maximize toggle | Aerospace intercepts / disable in System Settings |
| Cmd+Q | Quit application | Close window | Aerospace intercepts (consider Cmd+Shift+Q for quit) |
| Cmd+Tab | App switcher | (keep native) | No conflict -- Alt+Tab used for Aerospace cycling |
| Cmd+Space | Spotlight | Language switch | Reassign Spotlight, or use different lang-switch key |
| Cmd+, | App preferences | Prev workspace | Aerospace intercepts |
| Cmd+\` | Cycle app windows | Last workspace | Aerospace intercepts |

Conflicts are tracked reactively in `macREADME/KEY_CONFLICTS.md` as they are introduced.
