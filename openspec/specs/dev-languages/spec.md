## ADDED Requirements

### Requirement: Go installation
Go SHALL be installed on both OSes. On Ubuntu, it SHALL be installed via `install_scripts/install_go.sh`. On macOS, it SHALL be available via Homebrew or the macOS install scripts.

#### Scenario: Go available
- **WHEN** the install completes
- **THEN** `go` SHALL be on PATH

### Requirement: Rust and Cargo
Rust SHALL be installed via rustup on Ubuntu (`curl ... | bash -s -- -y` in `install_scripts/install_basic.sh`) and SHALL be available on macOS (via prior install or Homebrew). Cargo SHALL be the primary method for installing CLI tools on both platforms.

#### Scenario: Rust toolchain
- **WHEN** the install completes
- **THEN** `rustup`, `rustc`, and `cargo` SHALL be on PATH and `rustup update` SHALL have been run

### Requirement: Node.js and Bun
Node.js SHALL be installed on Ubuntu via npm→n (stable channel) and Bun SHALL be installed via its official installer. On macOS, Node/npm SHALL be available via Homebrew.

#### Scenario: Node available on Ubuntu
- **WHEN** the Ubuntu install completes
- **THEN** `node` (stable via n), `npm`, and `bun` SHALL be on PATH with npm prefix set to `~/.npm-packages`

### Requirement: Python and uv
Python3 SHALL be available on both OSes. `uv` SHALL be installed as the modern Python package manager (via `brew install uv` on macOS, available via install scripts on Ubuntu). pip SHALL be used for specific packages (libtmux, brotab) with `--break-system-packages` on newer distros.

#### Scenario: Python tooling
- **WHEN** the install completes
- **THEN** `python3`, `pip3`, and `uv` SHALL be available
