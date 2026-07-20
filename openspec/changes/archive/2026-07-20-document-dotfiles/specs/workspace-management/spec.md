## ADDED Requirements

### Requirement: ez-workspaces session picker
The system SHALL use ez-workspaces as the session/project picker. It provides a fuzzy-search interface (via fzf) to create, switch, and manage tmux sessions tied to project directories. The config SHALL be per-OS: `dotfiles/ez-workspaces/config.toml` on Ubuntu (→ `~/.config/ez/config.toml`) and `dotfiles/ez-workspaces-macos/config.toml` on macOS (→ `~/Library/Application Support/ez/config.toml`).

#### Scenario: Config per OS
- **WHEN** the install completes on Ubuntu
- **THEN** `~/.config/ez/config.toml` SHALL be symlinked with Linux workspace roots (`/home/ofirg/workspace/personal`, `/home/ofirg/workspace/work`)
- **WHEN** the install completes on macOS
- **THEN** `~/Library/Application Support/ez/config.toml` SHALL be symlinked with macOS workspace roots (`~/workspace/personal`, `~/workspace/work`)

### Requirement: Tmux integration
ez-workspaces SHALL use tmux as the session backend. `on_enter` and `on_create` SHALL both be set to `"tmux"`. When a workspace is selected, ez-workspaces SHALL attach to an existing tmux session or create a new one.

#### Scenario: Session creation
- **WHEN** a user selects a project that has no tmux session
- **THEN** ez-workspaces SHALL create a new tmux session named after the project and attach to it

### Requirement: Git worktree plugin
ez-workspaces SHALL have the `git-worktree` and `tmux` plugins enabled on both OSes. On macOS, additional plugins SHALL include `cursor-mcp-auth`, `cursor-mcp-approvals`, and `cursor-trusted-workspace`.

#### Scenario: Plugin differences
- **WHEN** checking the macOS config
- **THEN** it SHALL have cursor-related plugins in addition to the base git-worktree and tmux plugins

### Requirement: Session naming
ez-workspaces SHALL support structured session naming via `session_name_stages`: a prefix choice (feat/fix/chore), a ticket-prefix choice, and a free-text ticket number. On macOS, additional `name_builder_modes` SHALL include `full_name`, `build_from_parts`, `git_hub_pr`, and `jira_url`.

#### Scenario: Session name building
- **WHEN** creating a new session
- **THEN** the user SHALL be prompted through the session name stages (prefix → ticket-prefix → ticket-number)

### Requirement: Keybindings
ez-workspaces SHALL define consistent keybindings on both OSes: Alt+n (new session), Alt+d (delete), Alt+r (rename), Ctrl+t (tree view), Ctrl+w (workspace view), Ctrl+e (repo view), Ctrl+o (owner view), Ctrl+g (label view), Alt+l (edit labels). macOS SHALL additionally have Ctrl+d (cd session), Alt+N (bare session), Ctrl+s (sort toggle), Alt+s (session from dirty).

#### Scenario: Shared keybindings
- **WHEN** using ez-workspaces on either OS
- **THEN** the core navigation keybindings (Alt+n, Ctrl+t, Ctrl+e, etc.) SHALL work identically
