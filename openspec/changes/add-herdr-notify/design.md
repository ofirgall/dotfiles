## Context

tmux-notify (KoalaVim fork) is configured in `dotfiles/tmux_conf/plugins.tmux` with shell-hook mode on, a verbose message containing the finished command, `critical` urgency, and on-start/on-finish hooks that colour the tmux window and refresh agents-status. The day-to-day workflow is now herdr (0.8.x). herdr plugins are directories with a `herdr-plugin.toml` manifest declaring `[[actions]]` (bindable via `type = "plugin_action"`), `[[events]]` (e.g. `pane.closed`), `[[startup]]` and `[[panes]]`. Plugin commands run without a shell, from the plugin root, with `HERDR_PANE_ID`, `HERDR_TAB_ID`, `HERDR_WORKSPACE_ID`, `HERDR_BIN_PATH` and `HERDR_PLUGIN_*` in the environment. Plugins are installed from GitHub with `herdr plugin install <owner>/<repo> --yes` into the gitignored `dotfiles/herdr/plugins/github/`, or linked locally with `herdr plugin link` (as extrakto-herdr is).

## Goals / Non-Goals

**Goals:**
- Reproduce the tmux-notify behaviour actually in use: mark a pane, get notified with the command and exit code when the next prompt appears
- Visible in-progress indicator in the herdr sidebar
- Cheap: no polling loops, no long-lived processes

**Non-Goals:**
- Refocus-on-finish, configurable message templates, prompt-suffix polling, Telegram/Pushover, bell
- User on-start/on-finish/on-cancel hooks and agents-status integration
- Watching agent panes (herdr already tracks agent status)
- bash/fish hooks (zsh only; the hook can be ported later)

## Decisions

### Detection via zsh hook only
**Decision:** `preexec` stores `$1` (the command line); `precmd` captures `$?`, and if `~/.local/state/herdr-notify/$HERDR_PANE_ID.watch` exists, runs `notify.sh <exit> <cmd>` in the background (`&!`).
**Rationale:** Matches the current tmux setup (`@tnotify-shell-integration on`), gives an exact exit code and command, and costs one `[[ -f ]]` per prompt. `herdr pane wait-output` polling was considered for non-zsh panes and rejected as unnecessary for now.

### Fixed state path
**Decision:** State lives at `${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/<pane_id>.watch`, not `$HERDR_PLUGIN_STATE_DIR`.
**Rationale:** The zsh hook runs in the user's shell, not as a herdr plugin command, so it never sees `HERDR_PLUGIN_*` variables. Plugin actions and the shell hook must agree on one path (same approach as herdr-automatic-rename).

### Sentinel removed before notifying
**Decision:** `notify.sh` deletes the sentinel first, then clears the token and sends notifications.
**Rationale:** A slow notification path must not double-fire if another prompt is drawn meanwhile (same as tmux-notify's shell-hook.sh).

### Watch arms on the *next* command
**Decision:** `watch` only writes the sentinel. If a command is running, its completion fires the notification. If the pane is idle at a prompt, nothing fires until the user runs a command and it finishes, because `precmd` runs only after a command (the hook checks for a non-empty recorded command).
**Rationale:** Avoids an immediate spurious notification when watching an idle pane, and supports "watch, then start the long command".

### Notification channels
**Decision:** Send both an OS notification and a herdr toast.
- macOS: `notify-macos -u critical "<title>" "<body>"` if available, else `osascript`
- Linux: `notify-send -u critical "<title>" "<body>"`
- herdr: `herdr notification show "<title>" --body "<body>" --sound done`

**Message:** title `"<workspace label>|<tab label>"` (from `herdr workspace get` / `herdr tab get` for the pane), body `"<cmd> finished (exit N)"`. Not configurable.
**Rationale:** The OS notification reaches you outside herdr (the main use case). The toast is cheap and useful when herdr is in front.

### Sidebar token as indicator
**Decision:** `watch` reports `notify=⏳` under source `plugin:herdr-notify` on both the pane (`herdr pane report-metadata <pane> ...`) and its workspace (`herdr workspace report-metadata <ws> ...`). The sentinel stores the workspace id. Finish, cancel and cleanup clear the pane token, and clear the workspace token only when no other sentinel references that workspace. `common-config.toml` adds `{token = "$notify"}` to the `[ui.sidebar.spaces]` row.
**Rationale:** `[ui.sidebar.spaces]` rows render workspace tokens; pane tokens only render in `[ui.sidebar.agents]` rows, which list agent panes, not plain shells. This mirrors herdr-pr-tracker. It replaces the tmux `@window_color` highlight with no agents-status coupling. Note that the pane id must come before the options in `report-metadata`.

### Cleanup via events
**Decision:** `[[events]]` on `pane.closed` and `pane.exited` remove that pane's sentinel. The pane is gone, so its token goes with it.
**Rationale:** Pane IDs may be reused. A stale sentinel would otherwise fire on an unrelated future pane.

### Repo and install
**Decision:** Own repo `ofirgall/herdr-notify`. Develop at `~/workspace/personal/herdr-plugins/herdr-notify` with `herdr plugin link`, and install via `herdr plugin install ofirgall/herdr-notify --yes` in `install_herdr.sh`. `hooks.zsh` sources the zsh hook from the installed plugin root (resolved via `herdr plugin list` output or a stable path), guarded by `HERDR_PANE_ID`.
**Rationale:** Consistent with the other herdr plugins (extrakto-herdr, forks) and keeps plugin code out of dotfiles.

## Risks / Trade-offs

- [Installed plugin path contains a hash (`plugins/github/herdr-notify-<hash>`)] → `hooks.zsh` must resolve the path dynamically, or the plugin's `[[startup]]` can symlink its hook to a fixed location such as `~/.local/state/herdr-notify/hook.zsh`. Decide during implementation. Keep the per-shell-startup cost low (no `herdr plugin list` on every shell start if it's slow).
- [Pane ID reuse after server restart] → Cleanup events cover normal closes. A `[[startup]]` pass can also clear all sentinels on server start.
- [Non-zsh panes (ssh, docker) never fire] → Accepted. The watch just sits until cancel or pane close.
- [`herdr notification show` from a background process outside herdr's env] → `HERDR_PANE_ID`/socket are inherited by the shell, so the CLI reaches the server. Verify during implementation.
