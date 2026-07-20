## ADDED Requirements

### Requirement: Zsh as default shell
The system SHALL use zsh as the default shell on both macOS and Ubuntu. The zsh configuration SHALL be managed as a git submodule (`dotfiles/zsh-conf`).

#### Scenario: Shell setup
- **WHEN** the install completes
- **THEN** `~/.zshrc` SHALL symlink to `dotfiles/zsh-conf/entrypoint.zsh` and `~/.zshenv` SHALL symlink to `dotfiles/zsh-conf/env.zsh`

### Requirement: Zsh config structure
The zsh-conf submodule SHALL provide a modular config: `entrypoint.zsh` (main), `env.zsh` (environment variables), `aliases.zsh`, `binds.zsh`, `completions.zsh`, `hooks.zsh`, `plugins.zsh`, `plugin_settings.zsh`, `vars.zsh`, and `post_init.zsh`. Additional customizations SHALL live in `dotfiles/my-zsh-conf/` (symlinked to `~/.my-zsh-conf`).

#### Scenario: Config modularity
- **WHEN** examining the zsh config
- **THEN** each concern (aliases, binds, plugins, env) SHALL be in its own file, sourced by the entrypoint

### Requirement: Starship prompt
The system SHALL use Starship as the shell prompt. The config SHALL be at `dotfiles/zsh-conf/starship.toml`, shared across both OSes.

#### Scenario: Prompt consistency
- **WHEN** opening a terminal on either OS
- **THEN** the Starship prompt SHALL render with the same configuration

### Requirement: Profile
A shared `~/.profile` SHALL exist (symlinked from `dotfiles/profile`) for login shell configuration, available on both OSes.

#### Scenario: Profile symlink
- **WHEN** the install completes
- **THEN** `~/.profile` SHALL symlink to `dotfiles/profile`
