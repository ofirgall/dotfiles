# P1: Keyboard & System Behavior

Goal: Make macOS feel like Linux for keyboard interaction.

## Items

### Swap CapsLock and Escape
- **Linux source**: `awesomewm/autorun.sh` → `setxkbmap -option caps:escape`
- **macOS approach**: Karabiner-Elements simple modification (CapsLock → Escape only, Escape stays as Escape).
- **Status**: [x] Done
- **Notes**: Using Karabiner simple_modifications in `macos_migration/karabiner/karabiner.json`.

### Swap Fn and Left Ctrl (built-in keyboard)
- **Linux source**: Not needed on external keyboards; laptop-specific preference.
- **macOS approach**: Karabiner-Elements per-device simple modification: swap `apple_vendor_top_case_key_code: keyboard_fn` ↔ `left_control` for the built-in keyboard only (vendor_id: 0, product_id: 0).
- **Status**: [x] Done
- **Notes**: Uses `apple_vendor_top_case_key_code` for the Fn key (not regular `key_code`). Configured in `dotfiles/mac/karabiner/karabiner.json` under `devices` array.

### Swap Left Cmd and Left Option (built-in keyboard)
- **Linux source**: N/A — on PC keyboards, physical layout is Ctrl | Super | Alt | Space.
- **macOS approach**: Karabiner-Elements per-device simple modification: swap `left_command` ↔ `left_option` for the built-in keyboard only.
- **Status**: [x] Done
- **Notes**: After this swap the bottom row reads Ctrl | Super(Cmd) | Alt(Option) | Space, matching PC layout. Cmd is now in the physical Super/Option position (for Aerospace WM binds), Option is in the physical Cmd/Alt position (Ghostty's `macos-option-as-alt` makes it work as Alt for tmux).

### Backtick/tilde key (§± → `` ` ``/`~`)
- **Linux source**: Standard PC layout — key left of 1 is `` ` ``/`~`.
- **macOS approach**: Switch input source from "ABC" to "U.S." in System Settings > Keyboard > Input Sources. Also revert Karabiner keyboard type from ISO to ANSI.
- **Status**: [ ] Not started
- **Notes**: The "ABC" input source maps `grave_accent_and_tilde` keycode to §/±. The "U.S." input source maps it to `` ` ``/`~`. No Karabiner remapping needed — just change the input source.

### Ctrl-based shortcuts (copy, paste, cut, undo, select-all, new tab, close tab, etc.)
- **Linux source**: Default Linux behavior (Ctrl+C/V/X/Z/A/T/W/N).
- **macOS approach**: Karabiner complex rule that maps `left_control + <key>` → `command + <key>` for keys (c, v, x, z, a, f, w, t, n, tab) in all apps EXCEPT terminals and Cursor. Ghostty gets `ctrl+shift+c/v` keybinds for terminal copy/paste.
- **Status**: [x] Done
- **Notes**: Excluded apps: Ghostty, Terminal.app, iTerm2, Cursor. Cursor excluded to preserve raw Ctrl in its integrated terminal. Ghostty copy/paste via `ctrl+shift+c=copy:clipboard` and `ctrl+shift+v=paste:clipboard`.

### Right Alt as Backspace
- **Linux source**: `dotfiles/xmodmaprc` → `keycode 108 = BackSpace`
- **macOS approach**: Karabiner simple modification: `right_option` → `delete_or_backspace`.
- **Status**: [ ] Not started
- **Notes**: Simple 1:1 remap in Karabiner.

### Fast key repeat rate
- **Linux source**: `awesomewm/autorun.sh` → `xset r rate 200 35` (200ms delay, ~35 keys/sec)
- **macOS approach**:
  ```bash
  defaults write -g InitialKeyRepeat -int 10   # 166ms (10 * 16.67ms)
  defaults write -g KeyRepeat -int 1           # ~16ms between repeats (~60/sec)
  ```
  Requires logout to take effect.
- **Status**: [ ] Not started
- **Notes**: macOS values are in units of 16.67ms (60Hz frame time). `InitialKeyRepeat 10` ≈ 166ms, `KeyRepeat 1` is the fastest possible.

### Language switching (English/Hebrew)
- **Linux source**: AwesomeWM `Mod4+Space` via echuraev/keyboard_layout widget.
- **macOS approach**: System Settings > Keyboard > Input Sources. Set shortcut to Ctrl+Space (or keep as-is since it depends on Karabiner Ctrl mapping).
- **Status**: [ ] Not started
- **Notes**: macOS has built-in input source switching. Shortcut configurable in System Settings > Keyboard > Shortcuts > Input Sources.

## Tools

| Tool | Purpose | Install |
|------|---------|---------|
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | Keyboard remapping | `brew install --cask karabiner-elements` |

## Config file location

Karabiner config lives at `~/.config/karabiner/karabiner.json`. We'll store ours in `macos_migration/karabiner/` and symlink.

## Detailed Strategy

See [keylayout/](keylayout/) for the full key layout migration strategy, covering:
- Physical key remapping (Karabiner) with per-device rules
- Aerospace WM keybind mapping from AwesomeWM/Hyprland
- Ghostty terminal keybind changes
- macOS system settings and shortcut conflicts

## Implementation order

1. CapsLock ↔ Escape (quick win, native macOS)
2. Fast key repeat (one-liner defaults commands)
3. Install Karabiner
4. Fn ↔ Ctrl swap
5. Ctrl-based shortcuts with terminal exclusion
6. Right Alt → Backspace
7. Language switching
