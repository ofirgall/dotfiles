# P3: Advanced Dev Setup

Goal: Tiling window manager + workspace bar with agent status and notifications.

## Items

### Tiling window manager
- **Linux source**: `awesomewm/rc.lua`, `awesomewm/keymaps.lua`
- **macOS options**:
  - **Aerospace** (recommended): i3-like config, plain text, no SIP disable needed. Active development.
  - **yabai + skhd**: More mature, but advanced features (window opacity, moving spaces) require partial SIP disable.
- **Status**: [ ] Not started
- **Notes**: Key bindings to port from AwesomeWM:
  - `Mod+hjkl` — focus direction
  - `Mod+Shift+hjkl` — swap windows
  - `Mod+1-9` — switch workspace
  - `Mod+Shift+1-9` — move window to workspace
  - `Mod+Enter` — open terminal
  - `Mod+q` — close window
  - `Mod+f` — fullscreen toggle
  - `Mod+m` / `Mod+z` — maximize toggle
  - `Mod+Space` — language switch (handled by P1)
  - `Mod+,` / `Mod+.` — prev/next workspace
  - `` Mod+` `` — switch to last workspace
  - `Mod+o` — move window to other screen

### Workspace bar (SketchyBar)
- **Linux source**: AwesomeWM wibar (`awesomewm/rc.lua` lines 289-376) — shows workspaces, task list, CPU, RAM, battery, volume, spotify, clock, keyboard layout.
- **macOS approach**: [SketchyBar](https://github.com/FelixKratz/SketchyBar) — Lua or shell-scriptable bar. Can display:
  - Workspace indicators (with Aerospace/yabai integration)
  - Agent status (read from tmux window options or the Unix socket)
  - System stats (CPU, RAM, battery)
  - Clock, volume
  - Custom scripts for any data source
- **Status**: [ ] Not started
- **Notes**: SketchyBar is the most capable option. Alternatives: simple-bar (Übersicht), but less flexible.

### Agent status integration
- **Linux source**: `scripts/agents-status/server.py`, `scripts/agents-status/helpers.sh`
- **macOS approach**: The server is pure Python + Unix sockets — runs on macOS unchanged. Changes needed:
  - Replace `notify-send` calls with `terminal-notifier` or `osascript -e 'display notification...'`
  - Replace hyprctl workspace rename with SketchyBar trigger events (`sketchybar --trigger agent_status_changed`)
  - tmux integration (set-option, window colors) works identically
- **Status**: [ ] Not started
- **Notes**: This is the most unique part of the setup. The server.py architecture (Unix datagram socket, debounced notifications, subagent tracking) is fully portable. Only the side-effect commands need macOS equivalents.

### Desktop notifications
- **Linux source**: `scripts/notify/notify-send-wrapper`, uses `notify-send` with actions + urgency.
- **macOS approach**:
  - Basic: `osascript -e 'display notification "body" with title "title"'`
  - With actions/click handling: [terminal-notifier](https://github.com/julienXX/terminal-notifier) — supports `-execute` on click
  - `brew install terminal-notifier`
- **Status**: [ ] Not started
- **Notes**: The agent-status server uses notification actions ("Focus" button that switches to tmux session). terminal-notifier can replicate this with `-execute` flag running the focus script.

### Clipboard manager
- **Linux source**: CopyQ (`dotfiles/copyq.conf`), launched by AwesomeWM, toggled with `Mod+v`.
- **macOS options**:
  - [Maccy](https://maccy.app/) — lightweight, open source, `brew install --cask maccy`
  - Raycast clipboard history (if using Raycast as launcher)
  - CopyQ is also available on macOS: `brew install --cask copyq`
- **Status**: [ ] Not started
- **Notes**: Decide whether to keep CopyQ (familiar, vim mode) or go native. Maccy is simpler but lacks vim navigation.

### Screenshot tool
- **Linux source**: Flameshot (`awesomewm/keymaps.lua` — `Mod+p` → `flameshot gui -c`)
- **macOS approach**: Native `Cmd+Shift+4` (area), `Cmd+Shift+5` (full tool). Or [CleanShot X](https://cleanshot.com/) for annotation.
- **Status**: [ ] Not started
- **Notes**: macOS native screenshot is decent. Consider if annotation is needed.

### App launcher
- **Linux source**: AwesomeWM prompt box (`Mod+r`), rofi (hypr-dots)
- **macOS options**:
  - Spotlight (built-in, `Cmd+Space`)
  - [Raycast](https://www.raycast.com/) — extensible, clipboard history, snippets, window management
  - [Alfred](https://www.alfredapp.com/)
- **Status**: [ ] Not started
- **Notes**: Raycast is a strong option — covers launcher + clipboard + snippets + window hints.

## Architecture on macOS

```
┌─────────────────────────────────────────────────────────────┐
│                        SketchyBar                            │
│  [workspaces] [agent-status] [cpu] [ram] [battery] [clock]  │
└─────────────────────────────────────────────────────────────┘
         ▲                    ▲
         │                    │
    Aerospace           agents-status
    workspace              server.py
    events              (Unix socket)
                              ▲
                              │
                    ┌─────────┴──────────┐
                    │                     │
              cursor hooks          claude hooks
              (cli-wrapper)         (CLAUDE.md)
```

## Install order

1. Aerospace (tiling WM — immediate productivity)
2. Port keybindings from AwesomeWM
3. SketchyBar (bar with workspace indicators)
4. Agent status server adaptation (notify-send → terminal-notifier)
5. SketchyBar agent-status widget
6. Clipboard manager
7. Screenshot / launcher (low priority, macOS builtins work)

## Config file locations

| Tool | Config path |
|------|-------------|
| Aerospace | `~/.aerospace.toml` |
| SketchyBar | `~/.config/sketchybar/` |
| terminal-notifier | N/A (CLI tool) |
| Maccy | Preferences (GUI) |
