## ADDED Requirements

### Requirement: README overview section
The README SHALL begin with a brief overview describing what this dotfiles repo manages and its philosophy (vim-centric, tiling WM, terminal-first workflow).

#### Scenario: Reader opens README
- **WHEN** a user opens README.md
- **THEN** the first section SHALL describe the repo's purpose, supported platforms, and key tools

### Requirement: Platform support matrix
The README SHALL list all supported platforms (macOS, Linux/Ubuntu, Windows) with their key tools (window manager, terminal, status bar, key remapper).

#### Scenario: Platform listing
- **WHEN** a user reads the platform section
- **THEN** each platform SHALL list: window manager, terminal emulator, status bar, and key remapper used

### Requirement: Repo structure overview
The README SHALL include a directory tree or table showing the top-level repo structure with brief descriptions of each directory's purpose.

#### Scenario: Navigating the repo
- **WHEN** a user wants to find a config
- **THEN** the structure section SHALL map directory names to their purpose (e.g., `dotfiles/` → config files, `install_scripts/` → platform install scripts, `agents-status/` → submodule)

### Requirement: Install instructions per platform
The README SHALL document how to install on each supported platform with the exact commands to run.

#### Scenario: macOS install
- **WHEN** a user wants to bootstrap macOS
- **THEN** the README SHALL show the clone command and `./install-macos` invocation

#### Scenario: Linux install
- **WHEN** a user wants to bootstrap Linux
- **THEN** the README SHALL show the clone command, `./install` invocation, and mention `~/.remote_indicator` / `~/.no_sudo_indicator` flags

#### Scenario: Windows install
- **WHEN** a user wants to bootstrap Windows
- **THEN** the README SHALL show the clone command and the Windows install invocation

### Requirement: Submodule management section
The README SHALL document how to manage submodules using the Makefile (init, update, status, add, remove).

#### Scenario: Submodule quick reference
- **WHEN** a user wants to update submodules
- **THEN** the README SHALL show `make init` for first setup and `make update` to pull latest

### Requirement: Git user setup
The README SHALL document the git user config step (`~/.git_user`) required before committing.

#### Scenario: First-time contributor
- **WHEN** a user clones the repo for the first time
- **THEN** the README SHALL instruct them to create `~/.git_user` with their name and email

### Requirement: No stale content
The README SHALL NOT contain TODO lists, references to removed tools (AwesomeWM key mappings, Firefox extensions, taskwarrior), or outdated workflow descriptions.

#### Scenario: Content audit
- **WHEN** the README is reviewed
- **THEN** every tool and workflow mentioned SHALL correspond to an actively used component in the repo
