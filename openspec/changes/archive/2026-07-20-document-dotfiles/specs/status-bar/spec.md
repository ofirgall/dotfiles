## ADDED Requirements

### Requirement: SketchyBar on macOS
The system SHALL use SketchyBar as the status bar on macOS. The config SHALL live at `dotfiles/mac/sketchybar/` (symlinked to `~/.config/sketchybar`). SketchyBar SHALL be installed via `install_scripts/mac/install_sketchybar.sh`.

#### Scenario: SketchyBar setup
- **WHEN** the macOS install completes
- **THEN** SketchyBar SHALL be installed and configured with the dotfiles config

### Requirement: SketchyBar workspace indicators
SketchyBar SHALL display AeroSpace workspace indicators (workspaces 1-10) on the left side. Each workspace item SHALL subscribe to `aerospace_workspace_change_N` events and highlight when active. The appearance SHALL use CaskaydiaCove NFM font with a dark background (#151520).

#### Scenario: Workspace switching updates bar
- **WHEN** the user switches to workspace 3
- **THEN** SketchyBar SHALL highlight the workspace 3 indicator

### Requirement: SketchyBar system plugins
SketchyBar SHALL include plugins for: battery, bluetooth, clock, CPU, keyboard layout, media, RAM, volume, wifi, and window count. Plugin scripts SHALL live at `dotfiles/mac/sketchybar/plugins/`.

#### Scenario: System info display
- **WHEN** SketchyBar is running
- **THEN** system stats (battery, CPU, RAM, clock, etc.) SHALL be visible in the bar

### Requirement: agents-status integration
SketchyBar SHALL integrate with agents-status to display AI agent session info. The statusbar config in `agents-status-config.toml` SHALL specify `workspaces_provider = "aerospace"` and `bar = "sketchybar"` with a label template showing app icons, agent icon, and tmux sessions.

#### Scenario: Agent status in bar
- **WHEN** an AI agent session is active
- **THEN** SketchyBar SHALL display the agent status via the agents-status label template

### Requirement: Waybar on Ubuntu
The system SHALL use Waybar as the status bar on Ubuntu with Hyprland. The config SHALL live in the `hypr-dots` submodule (symlinked to `~/.config/waybar`).

#### Scenario: Waybar setup
- **WHEN** the Ubuntu/Hyprland install completes
- **THEN** Waybar SHALL be configured via the hypr-dots submodule
