## ADDED Requirements

### Requirement: Dotfiles purpose
The dotfiles repo SHALL serve as a portable, version-controlled configuration system that reproduces a complete development environment on a new machine. Cloning the repo and running the install entrypoint SHALL be sufficient to set up all tools, configs, and symlinks.

#### Scenario: New machine setup
- **WHEN** a user clones the repo on a fresh macOS or Ubuntu machine and runs the install entrypoint
- **THEN** all tools are installed, configs are symlinked, and the environment is ready to use

### Requirement: Target platforms
The system SHALL target macOS and Ubuntu as primary platforms. Windows/MSys support is deferred to the future. WSL is supported as a variant of the Ubuntu path.

#### Scenario: Platform coverage
- **WHEN** reviewing the install entrypoints and configs
- **THEN** there SHALL be a macOS entrypoint (`./install-macos`) and a Linux entrypoint (`./install`) covering Ubuntu

### Requirement: Linux-first interaction model
The system SHALL maintain a "Linux-first muscle memory" philosophy. macOS SHALL be configured to feel like Ubuntu/Hyprland — the same keybindings, window management paradigm, and terminal workflow SHALL work identically across both OSes. Users SHALL never need to context-switch their muscle memory when moving between machines.

#### Scenario: Cross-OS consistency
- **WHEN** a user presses Ctrl+C in a GUI app on macOS
- **THEN** it SHALL behave as copy (remapped to Cmd+C via Karabiner), matching Linux behavior

#### Scenario: Window management parity
- **WHEN** a user presses Super+1 on either OS
- **THEN** it SHALL switch to workspace 1, with the same grouped-workspace model on both platforms

### Requirement: Shared configs where possible
Configs that work identically across OSes SHALL be shared. Platform-specific differences SHALL be isolated to platform shims or separate config files, not forked copies of the entire config.

#### Scenario: Ghostty platform shim
- **WHEN** Ghostty is configured
- **THEN** a shared base `config` file SHALL exist with a `config.platform` symlink pointing to `config.linux` or `config.macos` for platform-specific overrides
