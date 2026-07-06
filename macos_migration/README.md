# macOS Migration

Tracking the migration of this Linux dotfiles repo to macOS. Not everything will be ported — items are prioritized and tracked individually.

## Progress

| Priority | Area | Status | File |
|----------|------|--------|------|
| P1 | Keyboard & System Behavior | Not started | [P1_keyboard_system.md](P1_keyboard_system.md) |
| P2 | Basic Dev Setup | Not started | [P2_basic_dev.md](P2_basic_dev.md) |
| P3 | Advanced Dev Setup | Not started | [P3_advanced_dev.md](P3_advanced_dev.md) |

## Priorities

### P1: Keyboard & System Behavior
Make the Mac feel like Linux. Ctrl-based shortcuts, swap Fn/Ctrl, CapsLock as Escape. This is the most important — without it the machine is unusable.

### P2: Basic Dev Setup
Ghostty terminal + Koala Vim + shell environment. Get a working dev workflow.

### P3: Advanced Dev Setup
Tiling window manager with workspace navigation, status bar showing agent status (Cursor/Claude) and notifications. Replicate the AwesomeWM + agents-status workflow.

## Approach

- Use Karabiner-Elements for keyboard remapping (replaces xmodmap/setxkbmap)
- Homebrew as package manager
- Ghostty has native macOS builds
- Aerospace or yabai for tiling WM (replaces AwesomeWM)
- SketchyBar for status bar (replaces AwesomeWM wibar)
- agents-status server.py is already portable (Unix sockets + Python)
