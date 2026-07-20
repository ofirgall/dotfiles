## ADDED Requirements

### Requirement: Git configuration
The system SHALL provide a shared `~/.gitconfig` (from `dotfiles/gitconfig`) and `~/.gitignore_global` (from `dotfiles/gitignore_global`) on both OSes. These SHALL configure core git behavior, aliases, and global ignore patterns.

#### Scenario: Git config symlinks
- **WHEN** the install completes on either OS
- **THEN** `~/.gitconfig` and `~/.gitignore_global` SHALL be symlinked to their dotfiles counterparts

### Requirement: Diff and merge tools
The system SHALL install `delta` (git-delta) as the pager/diff tool and `difftastic` as a structural diff tool. Both SHALL be installed via Cargo on both OSes.

#### Scenario: Diff tool installation
- **WHEN** the install scripts run on either OS
- **THEN** `cargo install git-delta` and `cargo install difftastic` SHALL be executed

### Requirement: GitHub dashboard
The system SHALL install and configure `gh-dash` for GitHub PR/issue dashboard. The config SHALL live at `dotfiles/gh-dash/config.yml`, symlinked to `~/.config/gh-dash/config.yml` on both OSes.

#### Scenario: gh-dash config
- **WHEN** the install completes
- **THEN** `~/.config/gh-dash/config.yml` SHALL be symlinked

### Requirement: Git utilities installation
Platform-specific git utilities SHALL be installed via `install_scripts/install_git_utils.sh` (Ubuntu) and `install_scripts/mac/install_git_utils.sh` (macOS).

#### Scenario: Git utils per OS
- **WHEN** the install runs
- **THEN** the platform-appropriate git utilities install script SHALL execute
