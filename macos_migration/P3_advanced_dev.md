# P3: Advanced Dev Setup

Goal: Tiling window manager + workspace bar with agent status and notifications.

## Remaining Items

### Agent status integration
- **Linux source**: `scripts/agents-status/server.py`, `scripts/agents-status/helpers.sh`
- **macOS approach**: The server is pure Python + Unix sockets — runs on macOS unchanged. Changes needed:
  - Replace `notify-send` calls with `terminal-notifier` or `osascript -e 'display notification...'`
  - Replace hyprctl workspace rename with SketchyBar trigger events (`sketchybar --trigger agent_status_changed`)
  - tmux integration (set-option, window colors) works identically
- **Status**: [ ] Not started

### Desktop notifications
- **Linux source**: `scripts/notify/notify-send-wrapper`, uses `notify-send` with actions + urgency.
- **macOS approach**:
  - Basic: `osascript -e 'display notification "body" with title "title"'`
  - With actions/click handling: [terminal-notifier](https://github.com/julienXX/terminal-notifier) — supports `-execute` on click
  - `brew install terminal-notifier`
- **Status**: [ ] Not started

### Clipboard manager
- **Linux source**: CopyQ (`dotfiles/copyq.conf`), launched by AwesomeWM, toggled with `Mod+v`.
- **macOS options**:
  - [Maccy](https://maccy.app/) — lightweight, open source, `brew install --cask maccy`
  - Raycast clipboard history (if using Raycast as launcher)
  - CopyQ is also available on macOS: `brew install --cask copyq`
- **Status**: [ ] Not started

### Screenshot tool
- **Linux source**: Flameshot (`awesomewm/keymaps.lua` — `Mod+p` → `flameshot gui -c`)
- **macOS approach**: Native `Cmd+Shift+4` (area), `Cmd+Shift+5` (full tool). Or [CleanShot X](https://cleanshot.com/) for annotation.
- **Status**: [ ] Not started

### App launcher
- **Linux source**: AwesomeWM prompt box (`Mod+r`), rofi (hypr-dots)
- **macOS options**:
  - Spotlight (built-in, `Cmd+Space`)
  - [Raycast](https://www.raycast.com/) — extensible, clipboard history, snippets, window management
  - [Alfred](https://www.alfredapp.com/)
- **Status**: [ ] Not started
