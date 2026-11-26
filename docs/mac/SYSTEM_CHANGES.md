# System Behavior Changes

Tracks which native macOS keybinds and behaviors we override or change.

## Keyboard

| Change | Method | Reason |
|--------|--------|--------|
| CapsLock → Escape | Karabiner simple_modification | Vim workflow, matches Linux setup |
| Fn ↔ Left Ctrl (built-in) | Karabiner per-device simple_modification | Puts Ctrl in bottom-left (PC position) |
| Left Cmd ↔ Left Option (built-in) | Karabiner per-device simple_modification | Puts Cmd(Super) in Option position, Option(Alt) in Cmd position — matches PC layout |
| Ctrl+{c,v,x,z,a,f,w,t,n,tab} → Cmd+{same} | Karabiner complex_modification | Linux-style shortcuts in GUI apps (excludes Ghostty, Terminal, iTerm2, Cursor) |
| Ctrl+Shift+C/V = copy/paste | Ghostty keybind | Linux terminal copy/paste |
| Option acts as Alt/Meta | Ghostty `macos-option-as-alt = true` | Tmux M- prefix and terminal Alt bindings |

## Window Decorations

| Change | Method | Reason |
|--------|--------|--------|
| Ghostty uses native decorations | `window-decoration = auto` | Needed for drag/resize/fullscreen on macOS |
| Ctrl+Shift+Enter = fullscreen | Ghostty keybind | No WM keybind, need terminal-level toggle |
