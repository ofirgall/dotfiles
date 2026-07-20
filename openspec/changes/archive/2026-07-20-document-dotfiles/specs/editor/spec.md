## ADDED Requirements

### Requirement: Neovim as primary editor
The system SHALL use Neovim with the KoalaVim/KoalaConfig configuration as the primary editor. KoalaConfig SHALL be a git submodule at `editors/KoalaConfig`, symlinked to `~/.config/nvim` and `~/.config/kvim-envs/main` on both OSes.

#### Scenario: Nvim config symlink
- **WHEN** the install completes on either OS
- **THEN** `~/.config/nvim` SHALL point to `editors/KoalaConfig` and `~/.kvim.conf` SHALL point to `dotfiles/.kvim.conf`

### Requirement: Neovim installation
On Ubuntu, Neovim SHALL be compiled from source via `install_scripts/install_nvim.sh`. On macOS, KoalaVim SHALL be installed via `install_scripts/mac/install_kvim.sh`. The `upgrade_nvim.sh` script SHALL support upgrading to a specific tag or nightly.

#### Scenario: Nvim install per OS
- **WHEN** the install runs on Ubuntu
- **THEN** Neovim SHALL be built from source
- **WHEN** the install runs on macOS
- **THEN** KoalaVim SHALL be installed via the mac-specific script

### Requirement: VS Code configuration
VS Code settings SHALL be managed as a git submodule at `editors/vscode-settings`. On Linux, settings and keybindings SHALL be symlinked to `~/.config/Code/User/`. Extensions SHALL be installed via `editors/vscode-settings/install_extensions.sh`.

#### Scenario: VS Code on Linux
- **WHEN** the Linux install runs
- **THEN** `~/.config/Code/User/settings.json` and `keybindings.json` SHALL be symlinked and extensions SHALL be installed

### Requirement: Cursor IDE support
Cursor IDE SHALL be supported with: a statusline script (`dotfiles/cursor/statusline.sh` → `~/.cursor/statusline.sh`) and cursor-cli-wrapper config (`dotfiles/cursor-cli-wrapper.toml` → `~/.config/cursor-cli-wrapper/config.toml`). Both SHALL be symlinked on both OSes.

#### Scenario: Cursor config symlinks
- **WHEN** the install completes
- **THEN** `~/.cursor/statusline.sh` and `~/.config/cursor-cli-wrapper/config.toml` SHALL be symlinked

### Requirement: Vimrc
A shared `~/.vimrc` SHALL exist (symlinked from `dotfiles/vimrc`) for basic Vim compatibility on both OSes.

#### Scenario: Vimrc symlink
- **WHEN** the install completes
- **THEN** `~/.vimrc` SHALL symlink to `dotfiles/vimrc`
