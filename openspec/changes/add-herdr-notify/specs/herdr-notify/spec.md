## ADDED Requirements

### Requirement: Watch a pane
The `herdr-notify` plugin SHALL provide a `watch` action (`herdr-notify.watch`) that marks the focused pane as watched. It does this by creating `${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/<pane_id>.watch` and storing the pane's workspace id in it. It SHALL report the metadata token `notify=⏳` (source `plugin:herdr-notify`) on both the pane and its workspace, because `[ui.sidebar.spaces]` rows render workspace tokens. Watching an already-watched pane SHALL leave the existing watch in place.

#### Scenario: Watch the focused pane
- **WHEN** the user presses `prefix+m` in a pane
- **THEN** the pane's sentinel file SHALL exist and the sidebar SHALL show the `$notify` token next to the pane's workspace

### Requirement: Notify on command completion
When a watched zsh pane returns to its prompt after running a command, the zsh hook SHALL send a notification and clear the watch. The notification SHALL have the title `<workspace label>|<tab label>` and the body `<command> finished (exit <status>)`. It SHALL be sent as an OS notification (`notify-macos`/`osascript` on macOS, `notify-send -u critical` on Linux) and as a herdr toast (`herdr notification show ... --sound done`). The sentinel SHALL be removed before any notification is sent, and the pane's `notify` token SHALL be cleared. The workspace token SHALL be cleared only when no other watched pane remains in that workspace.

#### Scenario: Long command finishes
- **WHEN** a pane is watched and `make build` finishes with exit status 2
- **THEN** an OS notification and a herdr toast SHALL appear with body `make build finished (exit 2)`
- **AND** the pane SHALL no longer be watched and its sidebar token SHALL be cleared

#### Scenario: Watching an idle prompt
- **WHEN** a pane at an idle prompt is watched and the user then runs `sleep 5`
- **THEN** no notification SHALL fire until `sleep 5` finishes, and exactly one notification SHALL fire then

#### Scenario: Unwatched pane
- **WHEN** a command finishes in a pane with no sentinel
- **THEN** no notification SHALL be sent

### Requirement: Cancel a watch
The plugin SHALL provide a `cancel` action (`herdr-notify.cancel`) that removes the focused pane's sentinel and clears its `notify` token without sending a notification.

#### Scenario: Cancel
- **WHEN** the user presses `prefix+shift+m` on a watched pane
- **THEN** the watch SHALL be removed, the token cleared, and no notification SHALL be sent when the running command finishes

### Requirement: Cleanup on pane close
The plugin SHALL subscribe to `pane.closed` and `pane.exited` events and remove the affected pane's sentinel.

#### Scenario: Watched pane closed
- **WHEN** a watched pane is closed
- **THEN** its sentinel file SHALL be deleted

### Requirement: Dotfiles integration
`install_scripts/mac/install_herdr.sh` SHALL install the plugin idempotently (`herdr plugin install ofirgall/herdr-notify --yes` when absent). `dotfiles/herdr/common-config.toml` SHALL bind `prefix+m` to `herdr-notify.watch` and `prefix+shift+m` to `herdr-notify.cancel`, and SHALL render the `$notify` token in the sidebar. `dotfiles/my-zsh-conf/hooks.zsh` SHALL source the plugin's zsh hook only when `HERDR_PANE_ID` is set.

#### Scenario: Fresh macOS install
- **WHEN** `install_herdr.sh` runs on a machine without the plugin
- **THEN** `herdr plugin list` SHALL include `herdr-notify`, and a new zsh shell inside herdr SHALL have the hook's `preexec`/`precmd` functions registered
