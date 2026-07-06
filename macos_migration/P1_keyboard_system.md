# P1: Keyboard & System Behavior

Goal: Make macOS feel like Linux for keyboard interaction.

## Items

### Swap CapsLock and Escape
- **Linux source**: `awesomewm/autorun.sh` → `setxkbmap -option caps:escape`
- **macOS approach**: System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys (built-in, no extra software). Alternatively Karabiner for more control.
- **Status**: [ ] Not started
- **Notes**: Native macOS support since Ventura. Karabiner only needed if you want tap=Escape, hold=Ctrl (dual-role).

### Swap Fn and Left Ctrl (built-in keyboard)
- **Linux source**: Not needed on external keyboards; laptop-specific preference.
- **macOS approach**: Karabiner-Elements complex rule: swap `fn` ↔ `left_control` for the built-in keyboard only (leave external keyboards untouched).
- **Status**: [ ] Not started
- **Notes**: This cannot be done in System Settings — Karabiner is required.

### Ctrl-based shortcuts (copy, paste, cut, undo, select-all, new tab, close tab, etc.)
- **Linux source**: Default Linux behavior (Ctrl+C/V/X/Z/A/T/W/N).
- **macOS approach**: Karabiner complex rule that maps `left_control + <key>` → `command + <key>` for a specific set of keys (c, v, x, z, a, t, w, n, f, tab) in all apps EXCEPT the terminal (where Ctrl must pass through raw). Terminal apps (Ghostty, iTerm, Terminal.app) should be excluded from this rule.
- **Status**: [ ] Not started
- **Notes**: This is the core of making macOS feel like Linux. Consider using a "per-app" condition in Karabiner so that terminals keep raw Ctrl. Alternatively, swap Cmd/Ctrl globally and handle exceptions.

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

## Implementation order

1. CapsLock ↔ Escape (quick win, native macOS)
2. Fast key repeat (one-liner defaults commands)
3. Install Karabiner
4. Fn ↔ Ctrl swap
5. Ctrl-based shortcuts with terminal exclusion
6. Right Alt → Backspace
7. Language switching
