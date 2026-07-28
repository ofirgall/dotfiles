## MODIFIED Requirements

### Requirement: Install entrypoints
The system SHALL provide two install entrypoints: `./install` for Linux (Ubuntu) and `./install-macos` for macOS. Each entrypoint SHALL invoke Dotbot with the appropriate config files. The README SHALL document these entrypoints with exact commands for each platform.

#### Scenario: Linux install
- **WHEN** `./install` is run
- **THEN** it SHALL run `common.conf.yaml` first, then `install.conf.yaml` (Linux-specific) unless `~/.remote_indicator` exists, in which case it stops after common

#### Scenario: macOS install
- **WHEN** `./install-macos` is run
- **THEN** it SHALL run `macos.conf.yaml` which includes both shared and macOS-specific links and install scripts

#### Scenario: README documents install
- **WHEN** a user reads the README install section
- **THEN** the documented commands SHALL match the actual entrypoint scripts and their behavior
