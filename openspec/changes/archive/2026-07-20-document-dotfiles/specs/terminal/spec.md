## ADDED Requirements

### Requirement: Ghostty as primary terminal
The system SHALL use Ghostty as the primary terminal emulator on both macOS and Ubuntu. The config SHALL live at `dotfiles/ghostty/` and be symlinked to `~/.config/ghostty`.

#### Scenario: Terminal installation
- **WHEN** the install completes on either OS
- **THEN** Ghostty SHALL be installed (via brew on macOS, via install script on Linux) and its config SHALL be symlinked

### Requirement: Platform shim pattern
Ghostty SHALL use a shared base `config` file for cross-platform settings (font, colors, padding, mouse behavior) and a `config.platform` symlink that points to `config.linux` or `config.macos` for platform-specific overrides. The install process SHALL create this symlink (`ln -sf config.linux` or `ln -sf config.macos`).

#### Scenario: macOS platform config
- **WHEN** `config.platform` points to `config.macos`
- **THEN** it SHALL set macOS-specific values: `font-size = 15`, `macos-option-as-alt = true`, fullscreen keybind (`ctrl+shift+enter`), F18/F17 text keybinds for tmux, and cursor warp shader

#### Scenario: Linux platform config
- **WHEN** `config.platform` points to `config.linux`
- **THEN** it SHALL set Linux-specific values: `font-size = 11`

### Requirement: Shared terminal appearance
The base Ghostty config SHALL define: CaskaydiaCove NFM font (ligatures disabled), black background (#000000), white foreground (#ffffff), no window decorations, no window padding, and the full 16-color palette. These SHALL be identical across OSes.

#### Scenario: Font and color consistency
- **WHEN** opening Ghostty on either OS
- **THEN** the font, colors, and window appearance SHALL be identical

### Requirement: Ghostty plugins
Ghostty SHALL support plugins (shaders). The `install_scripts/install_ghostty_plugins.sh` script SHALL install shared plugins. On macOS, cursor warp shaders SHALL be cloned to `~/.config/ghostty/shaders`.

#### Scenario: Plugin installation
- **WHEN** the install runs the ghostty plugins script
- **THEN** ghostty shader plugins SHALL be available

### Requirement: Alacritty legacy support
Alacritty SHALL remain in the repo as a legacy Linux terminal. Its config (`dotfiles/alacritty.toml`) and fonts (`dotfiles/alacritty-fonts`) SHALL be symlinked on Linux only. It is not installed or configured on macOS.

#### Scenario: Linux-only legacy terminal
- **WHEN** the Linux install runs
- **THEN** `~/.alacritty.toml` and `~/alacritty-fonts` SHALL be symlinked
