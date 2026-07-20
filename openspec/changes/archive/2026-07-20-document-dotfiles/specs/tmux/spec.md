## ADDED Requirements

### Requirement: Tmux config structure
Tmux SHALL be configured via a modular config rooted at `dotfiles/tmux_conf/entrypoint.tmux` (symlinked to `~/.tmux.conf`). The entrypoint SHALL source: `settings.tmux`, `design3.tmux` (status line), `plugins.tmux`, `binds.tmux`, and `hooks.tmux`. The full `dotfiles/tmux_conf/` directory SHALL be symlinked to `~/.tmux_conf`. Custom macros SHALL be symlinked to `~/.tmux/custom-macros`. This config SHALL be identical on both OSes.

#### Scenario: Tmux config layout
- **WHEN** the install completes
- **THEN** `~/.tmux.conf` SHALL source the modular config files and the config SHALL be shared across OSes

### Requirement: Tmux installation
On Ubuntu, tmux SHALL be compiled from the latest release tarball via `install_scripts/install_tmux.sh`. On macOS, tmux SHALL be installed via Homebrew. Both paths SHALL install TPM (Tmux Plugin Manager) and generate `~/.tmux/default-keys.conf` for clean reload support.

#### Scenario: Tmux install per OS
- **WHEN** the install runs on Ubuntu
- **THEN** tmux SHALL be compiled from source with libevent and ncurses dependencies
- **WHEN** the install runs on macOS
- **THEN** tmux SHALL be installed via `brew install tmux` and a custom terminfo SHALL be compiled for undercurl support

### Requirement: Nvim-aware keybindings
Tmux binds SHALL detect whether the active pane is running Neovim, a nested tmux session, fzf, or hunk. When Neovim or a nested session is active, keys SHALL be passed through. When not, tmux SHALL handle them directly. This applies to split (Alt+e/o), close (Alt+w/q), and navigation keys.

#### Scenario: Alt+e in nvim vs shell
- **WHEN** Alt+e is pressed in a pane running Neovim
- **THEN** the keypress SHALL be forwarded to Neovim (which creates a vertical split)
- **WHEN** Alt+e is pressed in a pane running a shell
- **THEN** tmux SHALL create a horizontal split pane

### Requirement: Nested session support
The tmux bind system SHALL support three contexts: inside Neovim (keys go to nvim), inside a nested tmux session (Shift modifier sends to nested session), and default (keys go to local tmux). This enables seamless remote development via SSH with `smux`.

#### Scenario: Shift modifier for nested sessions
- **WHEN** Alt+Shift+e is pressed inside a nested tmux session
- **THEN** the nested session SHALL receive the split command
- **WHEN** Alt+Shift+e is pressed inside Neovim
- **THEN** local tmux SHALL create a split (bypassing nvim)

### Requirement: Reload support
Tmux SHALL support clean reload via `prefix+r`. The reload SHALL unbind all keys, re-source default keybindings from `~/.tmux/default-keys.conf`, then re-source `~/.tmux.conf`. This ensures plugin keybindings don't accumulate across reloads.

#### Scenario: Clean reload
- **WHEN** the user presses prefix+r
- **THEN** all custom and plugin bindings SHALL be cleared and the config SHALL be re-sourced cleanly
