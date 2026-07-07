# System Behavior Changes

Tracks which native macOS keybinds and behaviors we override or change.

## Keyboard

| Change | Method | Reason |
|--------|--------|--------|
| CapsLock → Escape | Karabiner simple_modification | Vim workflow, matches Linux setup |
| Escape → CapsLock | Karabiner simple_modification | Full swap so CapsLock is still accessible |
| Fn ↔ Left Ctrl (built-in) | Karabiner per-device simple_modification | Puts Ctrl in bottom-left (PC position) |
| Left Cmd ↔ Left Option (built-in) | Karabiner per-device simple_modification | Puts Cmd(Super) in Option position, Option(Alt) in Cmd position — matches PC layout |
| Option acts as Alt/Meta | Ghostty `macos-option-as-alt = true` | Tmux M- prefix and terminal Alt bindings |

## Window Decorations

| Change | Method | Reason |
|--------|--------|--------|
| Ghostty uses native decorations | `window-decoration = auto` | Needed for drag/resize/fullscreen on macOS |
| Ctrl+Shift+Enter = fullscreen | Ghostty keybind | No WM keybind, need terminal-level toggle |
