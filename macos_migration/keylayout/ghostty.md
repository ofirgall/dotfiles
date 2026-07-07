# Ghostty Terminal Keybinds

Existing config: `dotfiles/ghostty/config`

## Already Configured

- `macos-option-as-alt = true` -- after the Cmd↔Option swap, the physical Cmd key (Alt position) sends Option, and Ghostty treats it as Alt. All tmux Alt+Shift binds work unchanged.
- All `alt+shift+*` escape sequence keybinds for tmux navigation
- All `ctrl+*` escape sequence keybinds for nvim
- `ctrl+shift+enter = toggle_fullscreen`

## Changes Needed

### Copy/Paste (Ctrl+Shift+C/V)

Add Linux-terminal-style copy/paste:

```
keybind = ctrl+shift+c=copy:clipboard
keybind = ctrl+shift+v=paste:clipboard
```

This gives the standard Linux terminal experience: Ctrl+C = SIGINT, Ctrl+Shift+C = copy.

## Key Behavior in Ghostty After All Remapping

| Physical Keys | Keycode Sent | Action |
|---|---|---|
| Bottom-left + C | Ctrl+C | SIGINT (raw, Karabiner excludes Ghostty) |
| Bottom-left + Shift + C | Ctrl+Shift+C | Copy (Ghostty keybind) |
| Bottom-left + B | Ctrl+B | tmux prefix |
| Alt-position + Shift + {letter} | Option+Shift+{letter} → Alt+Shift (macos-option-as-alt) | tmux navigation (escape sequences) |
| Bottom-left + hjkl | Ctrl+hjkl | nvim binds (escape sequences) |
