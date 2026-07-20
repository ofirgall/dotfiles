## ADDED Requirements

### Requirement: Install entrypoints
The system SHALL provide two install entrypoints: `./install` for Linux (Ubuntu) and `./install-macos` for macOS. Each entrypoint SHALL invoke Dotbot with the appropriate config files.

#### Scenario: Linux install
- **WHEN** `./install` is run
- **THEN** it SHALL run `common.conf.yaml` first, then `install.conf.yaml` (Linux-specific) unless `~/.remote_indicator` exists, in which case it stops after common

#### Scenario: macOS install
- **WHEN** `./install-macos` is run
- **THEN** it SHALL run `macos.conf.yaml` which includes both shared and macOS-specific links and install scripts

### Requirement: Dotbot config layering
The system SHALL use Dotbot as the orchestration tool with YAML config files defining symlinks, directory creation, and shell commands. Configs SHALL be layered: `common.conf.yaml` for cross-platform items, `install.conf.yaml` for Linux-specific items, and `macos.conf.yaml` for macOS (which duplicates common links — known duplication, to be resolved when Dotbot is replaced).

#### Scenario: Common config contents
- **WHEN** `common.conf.yaml` is processed
- **THEN** it SHALL symlink shared dotfiles (zshrc, gitconfig, tmux, nvim, ripgreprc, yazi, claude settings, etc.) and run shared install scripts (zsh, basic libs, TUIs, nvim, tmux, Go, wrappers, git utils)

#### Scenario: Linux config contents
- **WHEN** `install.conf.yaml` is processed
- **THEN** it SHALL symlink Linux-specific configs (vscode, fusuma, alacritty, awesomewm, hypr, copyq, desktop apps, systemd services, etc.) and run Linux-specific install scripts (vscode, fonts, ghostty, awesomewm, xdg defaults)

### Requirement: Submodule management
The system SHALL use git submodules for external or separately-versioned components. Submodules SHALL be initialized via `git submodule update --init --recursive` at the start of each install.

#### Scenario: Submodule inventory
- **WHEN** checking `.gitmodules`
- **THEN** the following submodules SHALL exist: `dotbot` (installer engine), `editors/KoalaConfig` (nvim config), `dotfiles/zsh-conf` (zsh config), `editors/vscode-settings`, `hypr-dots` (Hyprland config)

### Requirement: Environment indicators
The system SHALL support environment indicator files that modify install behavior. `~/.remote_indicator` SHALL cause `./install` to skip the local (Linux-specific) config. `~/.no_sudo_indicator` SHALL cause install scripts to skip commands requiring sudo.

#### Scenario: Remote environment
- **WHEN** `~/.remote_indicator` exists and `./install` is run
- **THEN** only `common.conf.yaml` SHALL be processed; `install.conf.yaml` SHALL be skipped

#### Scenario: No-sudo environment
- **WHEN** `~/.no_sudo_indicator` exists
- **THEN** install scripts SHALL skip `sudo apt install` commands and use user-local alternatives (e.g., pip --user, manual fzf install)

### Requirement: Manual setup steps
Certain macOS configurations SHALL require manual intervention after install. These SHALL be documented in `macREADME/MANUAL.md` and include: Karabiner permissions (Input Monitoring, Accessibility), AeroSpace Screen Recording permission, agents-status notification permission, and one-time system setup via `install_scripts/mac/setup_once.sh`.

#### Scenario: Post-install checklist
- **WHEN** `./install-macos` completes
- **THEN** `macREADME/MANUAL.md` SHALL list all manual steps required to complete the setup
