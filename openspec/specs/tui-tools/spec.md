## ADDED Requirements

### Requirement: CLI power tools
The system SHALL install a standard set of CLI tools on both OSes. The exact tool list is defined by the install scripts (`install_scripts/install_basic.sh` for Ubuntu, `install_scripts/mac/install_basic.sh` for macOS, and `install_scripts/install_tuis.sh` for Ubuntu TUIs). The goal is the same toolset on both platforms, installed via apt/cargo on Ubuntu and brew/cargo on macOS.

#### Scenario: Core tools present after install
- **WHEN** the install completes on either OS
- **THEN** the following tools SHALL be available: `fzf`, `ripgrep` (rg), `fd`, `bat`, `btop`/`bottom`, `jless`, `igrep`, `du-dust`, `fx`, `broot`

### Requirement: Tool configs
Tools with config files SHALL have their configs symlinked from the dotfiles repo. `~/.ripgreprc` SHALL come from `dotfiles/ripgreprc`. `~/.config/yazi` SHALL come from `dotfiles/yazi`. `~/.config/hunk` SHALL come from `dotfiles/hunk`. `~/.config/lumen` SHALL come from `dotfiles/lumen`. These SHALL be shared across OSes.

#### Scenario: Ripgrep config
- **WHEN** the install completes
- **THEN** `~/.ripgreprc` SHALL symlink to `dotfiles/ripgreprc`

### Requirement: Package manager differences
On Ubuntu, tools SHALL be installed via `apt`, `cargo`, `pip`, and `npm`. On macOS, tools SHALL be installed via `brew`, `cargo`, and `pip`. Cargo-installed tools (difftastic, du-dust, delta, jless, igrep, bottom, tuitab) SHALL use the same `cargo install` commands on both platforms.

#### Scenario: Shared cargo installs
- **WHEN** comparing `install_scripts/install_basic.sh` and `install_scripts/mac/install_basic.sh`
- **THEN** cargo-installed tools SHALL use identical install commands on both OSes

### Requirement: Rust toolchain
Rust/Cargo SHALL be available as a prerequisite for tool installation. On Ubuntu, rustup SHALL be installed via the official installer if not already present. On macOS, Rust SHALL be available via Homebrew or prior rustup install.

#### Scenario: Cargo available
- **WHEN** the basic install script runs
- **THEN** `cargo` SHALL be on PATH, either from a prior rustup install or installed by the script
