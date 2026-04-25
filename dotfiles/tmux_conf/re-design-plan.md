# design3.tmux rebuild plan

Goal: a fully customizable tmux status bar with **proper bubble-shaped pills**
(rounded caps `` ``), ergonomic per-module add/remove, and on-the-fly
per-window color override. **No plugin** (no nova, no oasis).

Strategy: rebuild from an empty file, adding **one thing at a time**.
After each step the user verifies the visual result before moving on.

Colors are deferred — early steps use hard-coded placeholder colors so we
can iterate on **style and components** first, then theme later.

## Step status legend

- [ ] not started
- [~] in progress / waiting for user verification
- [x] done & confirmed

---

## Step 1 — One bubble pill (style proof)  [x]

- [x] Picked cap glyph by side-by-side test (A/B/C/D/E).

## Step 2 — Bubble helper / template  [~]

- [x] First attempt: extract caps into `@bubble_l` / `@bubble_r` user options.
- [x] **Discovered tmux 3.6 bug**: format expansion `#{@option}` drops
  U+E0Bx glyphs from option values (option `length` reports 3 bytes, but
  expansion returns empty). Verified with isolated repro.
- [x] Workaround: inline the cap glyphs as literal bytes in every format
  string. Cap shape is fixed at the `design3.tmux` source level, not via
  options. Hollowed-edges variant captured in a comment for future use.
- [x] Kept tmux options for the parts that *do* expand correctly:
  `@bar_bg`, `@pill_bg`, `@pill_text`.
- [ ] **User verifies** the bubble still looks like Step 1's option A.

## Step 3 — Window tabs as bubbles  [x]

Confirmed working. Both active and inactive tabs render as bubbles.

## Step 4 — Per-window color override  [x]

Final design:
- `prefix W` (in `binds.tmux`) prompts for a color (hex or name).
  Sets `@window_color` to the user input. Empty input clears it.
- A hook (`after-select-window` + `window-linked` +
  `session-created` + `client-attached` in `hooks.tmux`) and an
  immediate refresh from the bind both call `refresh_dim_colors.sh`,
  which iterates every window and:
    - if `@window_color` is set: resolves it to bright hex (`factor=1.0`),
      writes it back to `@window_color`, AND writes the 50%-dim hex
      (`factor=0.5`) to `@window_color_dim`. Both options end up in the
      same palette so they read as bright/dim of the same hue.
    - if `@window_color` is unset: unsets `@window_color_dim`.
- `design3.tmux` helpers:
    - `@_d3_active_number_bg`   = `@window_color`     ?? default mauve
    - `@_d3_inactive_number_bg` = `@window_color_dim` ?? `@window_color` ?? default surface_1
- Result: tagged window's number circle is bright when focused, dim
  when in the background. Other (untagged) windows keep the theme
  defaults. External callers writing `tmux setw @window_color X`
  also work — the hook normalizes and computes the dim.

Files:
- `~/.tmux_conf/dim_color.sh` — color → hex resolution + brightness factor.
- `~/.tmux_conf/refresh_dim_colors.sh` — for-each-window sync.
- `~/.tmux_conf/tag_window_color.sh` — (legacy from v1, no longer used
  by the bind; safe to delete later).



Resumed after Step 4.5 stabilized the window style.

Scope (user-decided):
- Override applies to the **number section bg only** (left circle).
- Both active and inactive states pick up the override.
- For "dimmed active": added a SECOND option `@window_color_active`. If
  set, it overrides only the active number bg (the user picks a darker
  shade manually). If unset, falls back to `@window_color` so basic
  usage stays one-option.

Implementation:
- Two helper options computed once:
    - `@_d3_active_number_bg` —
      `@window_color_active` ?? `@window_color` ?? `@win_active_number_bg`
    - `@_d3_inactive_number_bg` —
      `@window_color` ?? `@win_inactive_number_bg`
- Window-status formats reference `#{E:@_d3_*_number_bg}` instead of
  the raw `@win_*_number_bg`.
- Keybind `prefix W` re-added in `binds.tmux`. Empty input clears both
  `@window_color` and `@window_color_active`. Hex/name/256-color all
  accepted.

Verified:
- default → active=mauve, inactive=surface_1
- `setw @window_color "#ff0000"` → both states red
- `+ setw @window_color_active "#660000"` → active dark red, inactive bright red

- [ ] **User verifies** in their session: tag with `prefix W` → name a
  color, switch windows, observe behavior.

## Step 4.5 — Window tab: bubble with thin ▏ seam  [~]

- [x] One outer bubble, rounded both ends, two bg color zones inside.
- [x] Number got a leading space restored so it's centered in its
  section (`<L> 1 ` instead of `<L>1 `).
- [x] Seam is now the **▏** (U+258F left one-eighth block) glyph drawn
  fg=number_bg on bg=name_bg — a thin vertical line at the boundary,
  marking where the bg color changes.
- [x] Format: `<L> #I ▏ #W <R>` — 2 caps + 1 thin seam.
- [ ] **User verifies** centering and the thin seam look.

## Step 5 — Status bar modules (one at a time)

For each: define the bubble, add to `status-left` or `status-right`,
reload, user confirms.

- [x] **session** — left, with drift-chore- prefix strip + 35-char trunc.
      `@mod_session_bg=surface_0`, `@mod_session_text=fg`, bold.
- [x] **whoami** — right, ` user@host`. surface_0 bg + fg text.
- [x] **github** — right, hidden when helper outputs nothing.
      Mauve bg + crust text. Body in `@_mod_github_body` to dodge the
      ternary-comma collision; helper called via `#(bash $HOME/...)`.
- [x] **current-ssh** — right, reads `/tmp/tmux_ssh_hosts_<session>`,
  hidden when empty. Sapphire bg + crust text.
- [x] **prefix** — right, only when `client_prefix`. Red bg + crust text.
- [x] **zoomed** — right, only when `window_zoomed_flag`. Peach bg + crust text.
- [x] **synced** — right, only when `pane_synchronized`. Yellow bg + crust text.

## Step 6 — Color theme  (REVERTED)

Tried a centralized `@thm_*` palette + `@bar_bg/@win_*` role
indirection layer. User decided it wasn't worth the extra layer —
reverted to inline hex per role/module. Each `@mod_*_bg` and
`@win_*_bg` keeps its own literal hex value.

## Step 7 — Polish

- [ ] Pane border styling.
- [ ] Message / mode-style.
- [ ] Suspended-mode handling (port from old design.tmux if still used).
- [ ] **session** module — refine the look (bg/text colors, bold,
  optional icon, padding, possibly a leading glyph). Currently using
  surface_0 bg + fg text + bold; revisit once the full status bar is
  in place.

---

## Decisions log

(Filled in as we go.)

- Cap glyph for bubbles: **A** — `` (U+E0B6) /  `` (U+E0B4) — Powerline-extra rounded
- Saved alternate: **hollowed_edges** — `` (U+E0B5) / `` (U+E0B7)
- Active window accent: _tbd_
- Inactive window accent: _tbd_
- `@window_color` keybind: _tbd (was `prefix W`)_
- Plugin used: **none**
