## ADDED Requirements

### Requirement: Canonical binding table
The system SHALL define a canonical set of keybindings that work identically across macOS and Ubuntu. The bindings are Linux/Hyprland-native; macOS achieves parity via remapping layers. The canonical bindings are:

**Window Management (Super layer):**
| Binding | Action |
|---|---|
| Super+hjkl | Focus window (crosses monitors) |
| Super+Shift+hjkl | Swap window |
| Super+1-9,0 | Switch workspace group |
| Super+Shift+1-9,0 | Move window to workspace (follow) |
| Super+Ctrl+1-9,0 | Move window to workspace (silent) |
| Super+q | Close window |
| Super+m | Maximize/accordion toggle |
| Super+n | Minimize/hide window |
| Super+o | Move window to next monitor |
| Super+s | Screenshot region to clipboard |
| Super+Shift+s | Screenshot UI toolbar to clipboard |
| Super+Shift+f | Float toggle |
| Super+Shift+r | Reload WM config |
| Super+, / Super+. | Previous/next workspace |
| Super+` | Last workspace |
| Super+/ | Layout toggle (h/v) |
| Super+p | Sticky window toggle |
| Super+r | App launcher (Raycast on macOS) |
| Super+Space | Toggle input language |
| Alt+Tab | Cycle windows in workspace |
| Alt+v | Clipboard history |
| Alt+1-9 | Switch browser tabs |

**Terminal/Tmux (Alt layer):**
| Binding | Action |
|---|---|
| Alt+e | Split horizontal (nvim or tmux) |
| Alt+o | Split vertical (nvim or tmux) |
| Alt+w / Alt+q | Close pane (nvim or tmux) |
| Alt+hjkl | Navigate panes (nvim or tmux) |
| Alt+Shift+{e,o,w} | Force tmux action (bypass nvim) |

**System (Ctrl layer):**
| Binding | Action |
|---|---|
| Ctrl+c/v/x/z/a/f/w/t/n/l/k | Standard GUI shortcuts |
| Ctrl+Shift+c/v | Terminal copy/paste |
| CapsLock | Escape |

#### Scenario: Binding parity
- **WHEN** a user presses Super+hjkl on either OS
- **THEN** window focus SHALL move in the expected direction with the same behavior

### Requirement: Karabiner translation layer
On macOS, Karabiner-Elements SHALL remap keys to achieve Linux-like behavior. The translation rules are:

1. **Ctrl→Cmd in GUI apps**: Left Ctrl + {c,v,x,z,a,f,w,t,n,l,k,+,-} SHALL be remapped to Left Cmd + same key, EXCEPT in terminals (Ghostty, Terminal, iTerm2, Cursor) where Ctrl SHALL pass through unchanged.
2. **Cmd→F-keys for AeroSpace**: Cmd+l→F16, Cmd+k→F15 (bypasses system shortcuts that would otherwise intercept these keys before AeroSpace sees them). Cmd+Space→F20, Ctrl+Space→F18, Ctrl+Shift+Space→F17, Option+Tab→F19.
3. **Terminal copy/paste**: Ctrl+Shift+C/V SHALL map to Cmd+C/V in terminals only.
4. **Browser tab switching**: Alt+1-9 SHALL be routed via AppleScript to switch browser tabs (bypassing AeroSpace workspace binds).

#### Scenario: Ctrl+C in browser vs terminal
- **WHEN** Ctrl+C is pressed in a browser on macOS
- **THEN** Karabiner SHALL remap it to Cmd+C (copy)
- **WHEN** Ctrl+C is pressed in Ghostty on macOS
- **THEN** Karabiner SHALL NOT remap it (Ctrl+C sends SIGINT)

### Requirement: Physical keyboard layout normalization
On the MacBook built-in keyboard, Karabiner SHALL swap: Fn↔Left Ctrl (puts Ctrl in PC bottom-left position) and Left Cmd↔Left Option (puts Super/Cmd in the Option position, matching PC layout where Super is between Ctrl and Alt). These swaps SHALL only apply to the built-in keyboard, not external keyboards.

#### Scenario: Built-in keyboard layout
- **WHEN** using the MacBook built-in keyboard
- **THEN** the physical key positions SHALL match a standard PC keyboard layout: Ctrl in bottom-left, then Super(Cmd), then Alt(Option)

### Requirement: Terminal keybind passthrough
Ghostty on macOS SHALL set `macos-option-as-alt = true` so that Option acts as Alt/Meta for tmux `M-` bindings and terminal Alt shortcuts. Ghostty SHALL also define keybinds for `ctrl+shift+enter` (fullscreen toggle), F18 and F17 (forwarded from Karabiner for tmux/Ctrl+Space and Ctrl+Shift+Space).

#### Scenario: Alt bindings in terminal
- **WHEN** Alt+e is pressed in Ghostty on macOS
- **THEN** the terminal SHALL receive Meta+e, which tmux SHALL interpret as the split binding

### Requirement: Key conflict tracking
Active key conflicts between the dotfiles config and native macOS shortcuts SHALL be tracked in `macREADME/KEY_CONFLICTS.md`. Each entry SHALL record the shortcut, native function, reassigned function, which tool introduces it, and whether the native behavior was disabled or relocated.

#### Scenario: Conflict documentation
- **WHEN** a new keybinding override is introduced
- **THEN** it SHALL be documented in `macREADME/KEY_CONFLICTS.md`
