## ADDED Requirements

### Requirement: Scripts directory
The system SHALL provide a collection of utility scripts at `scripts/` (symlinked to `~/dotfiles_scripts` on both OSes). Scripts SHALL be organized by subdirectory.

#### Scenario: Scripts symlink
- **WHEN** the install completes on either OS
- **THEN** `~/dotfiles_scripts` SHALL symlink to `scripts/`

### Requirement: Cursor scripts
The `cursor/` subdirectory SHALL contain Cursor IDE utilities.

| Script | Purpose | OS |
|---|---|---|
| `copy-conv.sh` | Copy a Cursor conversation between workspaces (by UUID, copies agent-transcripts + chats) | All |

#### Scenario: Cursor scripts present
- **WHEN** listing `~/dotfiles_scripts/cursor/`
- **THEN** the Cursor utility scripts SHALL be present

### Requirement: Deploy scripts
The `deploy/` subdirectory SHALL contain quick build-and-deploy shortcuts for different project types.

| Script | Purpose | OS |
|---|---|---|
| `go` | `go build .` | All |
| `rust` | `cargo lbuild` | All |
| `playground` | `./run` | All |
| `volumez` | Cross-compile Go test binary and scp to remote host | All |

#### Scenario: Deploy dispatch
- **WHEN** `~/dotfiles_scripts/misc/deploy` is run from a project root
- **THEN** it SHALL look for a matching deploy script in `~/dotfiles_scripts/deploy/` based on the project

### Requirement: Git extension scripts
The `git/` subdirectory SHALL contain git workflow extensions, usable as `git <name>` subcommands.

| Script | Purpose | OS |
|---|---|---|
| `git-new-session` | Create worktree + tmux session for a new branch | All |
| `git-del-session` | Delete worktree + tmux session for a branch | All |
| `git-squash` | Squash N commits (auto-detects base branch) | All |
| `git-rsync` | Rsync dirty/committed files to a remote host | All |
| `compare_rebased_branch.sh` | Diff a branch before vs after rebase | All |
| `git_fork.sh` | Add `fork` remote pointing to ofirgall/<repo> | All |
| `git_tossh.sh` | Convert HTTP remote URL to SSH | All |
| `del_git_user.sh` | Unset local git user.email/user.user | All |
| `link_env.sh` | Symlink env files into a worktree | All |
| `listfiles.sh` | List files changed between commits | All |

#### Scenario: Git subcommands
- **WHEN** `git new-session` or `git squash` is run
- **THEN** the corresponding script from `~/dotfiles_scripts/git/` SHALL execute

### Requirement: Inner scripts
The `inner/` subdirectory SHALL contain scripts called by tmux, nvim, or aliases — not invoked directly by the user.

| Script | Purpose | OS |
|---|---|---|
| `kill_pane.sh` | Smart kill — skips if last pane in last window | All |
| `osc52_yank.sh` | Yank text via OSC52 escape sequence (works over SSH) | All |
| `inner_cg.sh` | `cg` alias backend — fuzzy cd into git repos | All |
| `_on_tmux_attach.sh` | Hook: runs when tmux session is attached | All |
| `_tmuxjump_capture.sh` | Capture file:line references from tmux panes for nvim jump | All |

#### Scenario: Inner scripts not called directly
- **WHEN** examining inner scripts
- **THEN** they SHALL be invoked by tmux binds, nvim, or shell aliases, not run standalone

### Requirement: Notification scripts
The `notify/` subdirectory SHALL provide a cross-OS notification abstraction.

| Script | Purpose | OS |
|---|---|---|
| `notify-macos` | notify-send-compatible wrapper using alerter | macOS |
| `notify-send.sh` | Enhanced notify-send with actions, replace, close | Ubuntu |
| `notify-send-wrapper` | Dispatcher: routes to notify-send.sh or Windows | Ubuntu/WSL |
| `notify-action.sh` | Listen for dbus notification actions and run callbacks | Ubuntu |
| `windows_notify.ps1` | Balloon notification via PowerShell | Legacy (Windows) |

#### Scenario: Cross-OS notification
- **WHEN** a script calls `notify-macos` on macOS or `notify-send-wrapper` on Ubuntu
- **THEN** a native OS notification SHALL appear with the specified title and body

### Requirement: Misc utility scripts
The `misc/` subdirectory SHALL contain standalone utilities.

| Script | Purpose | OS |
|---|---|---|
| `toclip` | Universal clipboard — routes to pbcopy/wl-copy/xclip/clip.exe/osc52 | All |
| `smux` | SSH and attach to remote tmux session with same name as local | All |
| `rssh` | Retry SSH in a loop, notify on success | All |
| `assh` | Auto-reconnect SSH (wraps rssh in infinite loop) | All |
| `wait_for_ssh` | Block until host is reachable via SSH | All |
| `deploy` | Smart deploy — finds per-project deploy script by git root | All |
| `select_tmux_session.sh` | Interactive tmux session picker with fzf | All |
| `sshconf` | Python CLI to edit ~/.ssh/config entries | All |
| `scp-env` | scp files to all matching hosts in ssh config | All |
| `upgrade_nvim.sh` | Download and compile neovim from tag/commit | Ubuntu |
| `codex-latest-plan.sh` | Extract latest Codex plan-mode output as markdown | All |
| `gpt` | Open nvim with ChatGPT plugin (wrapper for tmux-window-name) | All |
| `docker-compose` | Alias wrapper for `docker compose` | All |
| `sort_lock_stats.py` | Parse/sort Linux lock contention stats | Ubuntu |
| `segfault.py` | Parse Linux kernel segfault log lines | Ubuntu |
| `edit_compile_commands.py` | Edit compile_commands.json for C++ dev | All |

#### Scenario: Universal clipboard
- **WHEN** `toclip` is piped data on macOS
- **THEN** it SHALL route to `pbcopy`
- **WHEN** `toclip` is piped data on Ubuntu/Wayland
- **THEN** it SHALL route to `wl-copy`
- **WHEN** `toclip` is piped data on a remote machine
- **THEN** it SHALL route to `osc52_yank.sh`

### Requirement: Helper libraries
The `helpers/` subdirectory SHALL contain shared shell functions sourced by other scripts.

| Script | Purpose | OS |
|---|---|---|
| `git.sh` | Git helpers (get_branch, worktree root) | All |
| `prompt.sh` | Interactive yes/no prompts | All |

#### Scenario: Helper sourcing
- **WHEN** a script needs git branch detection
- **THEN** it SHALL `source ~/dotfiles_scripts/helpers/git.sh`

### Requirement: Tmux management scripts
The `tmux/` subdirectory SHALL contain tmux session management utilities.

| Script | Purpose | OS |
|---|---|---|
| `redo_worktree_sessions.sh` | Reconcile tmux sessions with existing git worktrees | All |
| `save_current_attached.sh` | Snapshot attached clients list to file | All |

#### Scenario: Worktree session reconciliation
- **WHEN** `redo_worktree_sessions.sh` is run
- **THEN** it SHALL create/delete tmux sessions to match existing git worktrees

### Requirement: Tmux layout scripts
The `tmux_layouts/` subdirectory SHALL contain predefined tmux window layouts for common tasks.

| Script | Purpose | OS |
|---|---|---|
| `ssh-env` | Open split panes to all SSH hosts (tiled layout) | All |
| `viewer` | Multi-pane dashboard: mdstat + lsblk + free + log shell on remote | All |
| `viewer_laptop` | Same as viewer, optimized for smaller screen | All |

#### Scenario: Layout creation
- **WHEN** `~/dotfiles_scripts/tmux_layouts/viewer ut` is run
- **THEN** a multi-pane tmux layout SHALL be created with SSH connections to the specified host

### Requirement: Settings scripts
The `settings/` subdirectory SHALL contain system settings utilities.

| Script | Purpose | OS |
|---|---|---|
| `control_brightness.sh` | Set/adjust screen brightness via xrandr | Ubuntu |

#### Scenario: Brightness control
- **WHEN** `control_brightness.sh +0.1` is run on Ubuntu
- **THEN** screen brightness SHALL increase by 0.1

### Requirement: IO test scripts
The `io/` subdirectory SHALL contain low-level I/O testing utilities.

| Script | Purpose | OS |
|---|---|---|
| `gen_chunk_file.py` | Generate a file of given size with specified chunk pattern | All |
| `write_sparsed.py` | Write double-sparse on a block device (thin provisioning testing) | Ubuntu |

#### Scenario: IO tools present
- **WHEN** listing `~/dotfiles_scripts/io/`
- **THEN** the IO test utilities SHALL be present
