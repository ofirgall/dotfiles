## ADDED Requirements

### Requirement: Tiling window management on both OSes
The system SHALL provide tiling window management with the same interaction model on both platforms: Hyprland on Ubuntu and AeroSpace on macOS. AwesomeWM configs remain in the repo as legacy but Hyprland is the active Ubuntu WM.

#### Scenario: WM per platform
- **WHEN** the system is set up on Ubuntu
- **THEN** Hyprland SHALL be the window manager (config in `hypr-dots` submodule)
- **WHEN** the system is set up on macOS
- **THEN** AeroSpace SHALL be the window manager (config at `dotfiles/mac/aerospace/aerospace.toml`)

### Requirement: Grouped workspaces
Both WMs SHALL support grouped workspaces across monitors. Each workspace group N SHALL have sub-workspaces for each monitor (N, Nb, Nc). Switching to workspace N SHALL switch all monitors to their respective sub-workspace simultaneously.

#### Scenario: Multi-monitor workspace switch
- **WHEN** the user presses Super+1 with three monitors
- **THEN** monitor 1 SHALL show workspace 1, monitor 2 SHALL show workspace 1b, monitor 3 SHALL show workspace 1c

### Requirement: AeroSpace helper scripts
AeroSpace SHALL use helper scripts in `dotfiles/mac/aerospace/` for complex operations: `switch-group.sh` (workspace switching), `move-to-group.sh` (move window), `move-all-to-group.sh` (move all windows), `swap-window.sh` (cross-monitor swap), `cycle-window.sh` (Alt+Tab within workspace), `sticky-toggle.sh` (pin window across workspaces), `switch-group-relative.sh` (prev/next workspace), `switch-group-back.sh` (last workspace), and `close-window.sh`.

#### Scenario: Script-backed operations
- **WHEN** the user presses Super+1 on macOS
- **THEN** AeroSpace SHALL execute `switch-group.sh 1` which switches all monitors to group 1

### Requirement: Window focus and movement
Both WMs SHALL use Super+hjkl for window focus (crossing monitor boundaries) and Super+Shift+hjkl for window swap. On macOS, Karabiner remaps Cmd+k and Cmd+l to F15/F16 to avoid system shortcut conflicts, and AeroSpace binds F15/F16 for up/right focus.

#### Scenario: Focus navigation
- **WHEN** Super+h is pressed on either OS
- **THEN** focus SHALL move to the window on the left, crossing monitor boundaries if needed

### Requirement: Workspace monitor assignment
AeroSpace SHALL assign workspaces to monitors by physical position: primary workspaces (1-10) to monitor 1, secondary (1b-10b) to monitor 2, tertiary (1c-10c) to monitor 3. With fewer monitors, workspaces SHALL fall back to available monitors.

#### Scenario: Two-monitor setup
- **WHEN** only two monitors are connected
- **THEN** primary workspaces SHALL be on monitor 1, secondary on monitor 2, and tertiary SHALL fall back to monitor 2 then monitor 1

### Requirement: AwesomeWM legacy
AwesomeWM configs SHALL remain in `awesomewm/` for reference. The config includes `rc.lua`, `keymaps.lua`, `plugins.lua`, `ui.lua`, and helper scripts. It is not actively maintained but is symlinked to `~/.config/awesome` on Linux installs.

#### Scenario: Legacy config presence
- **WHEN** examining the repo
- **THEN** `awesomewm/` SHALL exist with a complete AwesomeWM configuration, noted as legacy
