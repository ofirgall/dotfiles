## ADDED Requirements

### Requirement: LinearMouse on macOS
The system SHALL use LinearMouse on macOS to control trackpad and mouse behavior. The config SHALL live at `dotfiles/mac/linearmouse/linearmouse.json` (symlinked to `~/.config/linearmouse/linearmouse.json`). LinearMouse SHALL be installed via `install_scripts/mac/install_linearmouse.sh`.

#### Scenario: LinearMouse installation
- **WHEN** the macOS install completes
- **THEN** LinearMouse SHALL be installed and its config SHALL be symlinked

### Requirement: Trackpad configuration
On macOS, the trackpad SHALL be configured with: tap-to-click enabled, "Without Drag Lock" drag style, low acceleration (not fully disabled — Apple limitation on M-series), and natural scrolling. The built-in trackpad SHALL have acceleration enabled (1.0) while external trackpads SHALL have acceleration disabled.

#### Scenario: Built-in vs external trackpad
- **WHEN** using the MacBook built-in trackpad
- **THEN** acceleration SHALL be enabled at 1.0
- **WHEN** using an external trackpad
- **THEN** acceleration SHALL be disabled

### Requirement: Mouse configuration
On macOS, external mice (e.g., Logitech USB Receiver) SHALL have: acceleration disabled, reverse vertical scroll (to match natural scrolling being on for trackpad), and custom scroll speed (28). These SHALL be configured per-device in LinearMouse.

#### Scenario: External mouse scroll
- **WHEN** scrolling with the external mouse
- **THEN** vertical scroll SHALL be reversed and acceleration SHALL be disabled

### Requirement: Trackpad documentation
Trackpad behavior and alternatives SHALL be documented in `macREADME/TOUCHPAD.md`, including gesture reference (tap, double-tap, right-click, scroll, drag, select-extend) and notes about drag delay workarounds.

#### Scenario: Trackpad docs present
- **WHEN** reviewing macREADME/
- **THEN** `TOUCHPAD.md` SHALL describe all trackpad gestures and configuration

### Requirement: libinput on Ubuntu
On Ubuntu, pointing device configuration SHALL use libinput (the Wayland/Hyprland default). Configuration details SHALL live in the hypr-dots submodule.

#### Scenario: Ubuntu pointer config
- **WHEN** the Ubuntu/Hyprland setup is active
- **THEN** pointer behavior SHALL be configured via libinput/Hyprland settings
