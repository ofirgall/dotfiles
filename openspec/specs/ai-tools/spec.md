## ADDED Requirements

### Requirement: Claude Code settings
The system SHALL provide a shared Claude Code settings file at `dotfiles/claude/settings.json`, symlinked to `~/.claude/settings.json` on both OSes. This ensures consistent Claude Code behavior across machines.

#### Scenario: Claude settings symlink
- **WHEN** the install completes on either OS
- **THEN** `~/.claude/settings.json` SHALL symlink to `dotfiles/claude/settings.json`

### Requirement: cursor-cli-wrapper
The system SHALL configure cursor-cli-wrapper via `dotfiles/cursor-cli-wrapper.toml`, symlinked to `~/.config/cursor-cli-wrapper/config.toml` on both OSes. This wraps the Cursor CLI with additional functionality.

#### Scenario: cursor-cli-wrapper config
- **WHEN** the install completes
- **THEN** `~/.config/cursor-cli-wrapper/config.toml` SHALL be symlinked

### Requirement: agents-status
agents-status (a KoalaVim org tool) SHALL be installed from its git repo (`git@github.com:KoalaVim/agents-status.git`) to `~/agents-status`. The core SHALL be installed via `uv tool install` (or fallback installer). Hooks SHALL be installed for relevant editors. On macOS, `alerter` SHALL additionally be installed via Homebrew for native notifications.

#### Scenario: agents-status on macOS
- **WHEN** the macOS install runs
- **THEN** agents-status core SHALL be installed, alerter SHALL be available, and hooks SHALL be installed for cursor and codex

#### Scenario: agents-status on Ubuntu
- **WHEN** the Ubuntu install runs
- **THEN** agents-status core SHALL be installed, hooks SHALL be installed for all editors, and cursor-cli-wrapper SHALL be set up

### Requirement: agents-status configuration
The agents-status config SHALL live at `dotfiles/agents-status-config.toml` (symlinked to `~/.config/agents-status/config.toml`). On macOS, it SHALL configure: `notify-macos` as the notification command, post-event commands for tmux dim color refresh and sketchybar statusbar update, and sketchybar integration with a label template showing app icons, agent icon, and tmux sessions.

#### Scenario: Notification routing
- **WHEN** an agent event fires on macOS
- **THEN** agents-status SHALL notify via `notify-macos` and update the SketchyBar statusbar widget
