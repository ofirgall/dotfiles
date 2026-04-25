### SETTINGS ###
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g display-panes-time 800
set -g display-time 1000
set -g monitor-activity off
set -g visual-activity off
set -g status-left-length 1000
set -g status-right-length 1000
set -g set-titles-string "#S - TMUX"
set -g set-titles on

set -q -g status-utf8 on
setw -q -g utf8 on

# ─────────────────────────────────────────────────────────────────────
# KNOWN TMUX BUG (verified on tmux 3.6a, 2026-04-25)
# ─────────────────────────────────────────────────────────────────────
# Format expansion `#{@option}` silently DROPS Powerline-extra glyphs
# (U+E0B0..U+E0BF) from user-option values. The option stores the bytes
# correctly (visible via show-options + xxd), but every reference
# through #{@name} or #{E:@name} in a status format expands to
# empty. WORKAROUND: inline the cap glyphs as literal bytes in the
# format string. Colors and other multi-char strings expand fine.
#
# Repro:
#   set -g @testbub ""
#   show-options -g @testbub                    # prints the glyph
#   display-message -p '#{@testbub}' | xxd     # 0a only — empty
#   display-message -p '#{n:@testbub}'         # 3 (byte length)
# ─────────────────────────────────────────────────────────────────────

### BUBBLE STYLE ###
# Window tab — single outer bubble with two color sections inside,
# joined by a thin ▏ seam (fg=number_bg on bg=name_bg):
#
#   <L> #I ▏#W <R>
#
# Cap glyphs (U+E0B6 / U+E0B4) inlined as literal bytes — see bug above.
# Hollowed-edges variant for future use:  /  ‌

# Pane bg — explicitly unset so a reload restores tmux default
# (terminal bg). Otherwise an old `bg=…` value from a prior reload
# would persist.
set -u window-style
set -u window-active-style

### COLORS ###
set -g @bar_bg    "#181825"
set -g @pill_bg   "#cba6f7"
set -g @pill_text "#11111b"

# Window tab colors — number on accent, name on surface_0.
set -g @win_active_number_bg   "#cba6f7"
set -g @win_active_number_text "#11111b"
set -g @win_active_name_bg     "#313244"
set -g @win_active_name_text   "#cdd6f4"
set -g @win_inactive_number_bg   "#45475a"
set -g @win_inactive_number_text "#cdd6f4"
set -g @win_inactive_name_bg     "#313244"
set -g @win_inactive_name_text   "#bac2de"


# Resolved number-circle bg per state.
#   @window_color      = bright accent (used when window is ACTIVE)
#   @window_color_dim  = 50%-dim variant (used when window is INACTIVE)
# @window_color_dim is auto-derived from @window_color by hooks.tmux.
set -g @window_color ""
set -g @window_color_dim ""
set -g @_d3_active_number_bg   "#{?#{!=:#{@window_color},},#{@window_color},#{@win_active_number_bg}}"
set -g @_d3_inactive_number_bg "#{?#{!=:#{@window_color_dim},},#{@window_color_dim},#{?#{!=:#{@window_color},},#{@window_color},#{@win_inactive_number_bg}}}"

### STATUS BAR ###
set -g status-style "bg=#{@bar_bg},fg=#cdd6f4"
set -g status-justify "left"

### MODULES ###
# Each module is a self-contained bubble. Optional modules use
# #{?cond,#{E:@_mod_xxx_body},} so they vanish when not applicable.
#
# Indirection trick (catppuccin/oasis pattern): commas inside #[bg=X,fg=Y]
# clash with #{?cond,then,else} branch separators, so styled bodies of
# conditional modules are stored in their own @_mod_*_body option and
# pulled in via #{E:...}.

# session — drift-chore- prefix strip + 35-char truncation
set -g @mod_session_bg   "#313244"
set -g @mod_session_text "#cdd6f4"
set -g @mod_session "#[fg=#{@mod_session_bg},bg=#{@bar_bg}]#[fg=#{@mod_session_text},bg=#{@mod_session_bg},bold] #{=35:#{s/^drift-chore-//:session_name}} #[fg=#{@mod_session_bg},bg=#{@bar_bg}]"

# whoami — user@host
set -g @mod_whoami_bg   "#313244"
set -g @mod_whoami_text "#cdd6f4"
set -g @mod_whoami "#[fg=#{@mod_whoami_bg},bg=#{@bar_bg}]#[fg=#{@mod_whoami_text},bg=#{@mod_whoami_bg}] #(whoami)@#h #[fg=#{@mod_whoami_bg},bg=#{@bar_bg}]"

# github — current authenticated github account, hidden when empty.
# Body is in @_mod_github_body so the comma-laden #[bg=X,fg=Y]
# directives don't collide with the #{?cond,then,else} parser.
set -g @mod_github_bg   "#cba6f7"
set -g @mod_github_text "#11111b"
set -g @_mod_github_body "#[fg=#{@mod_github_bg},bg=#{@bar_bg}]#[fg=#{@mod_github_text},bg=#{@mod_github_bg},bold]  #(bash $HOME/.tmux_conf/helpers.sh get_github_user_name) #[fg=#{@mod_github_bg},bg=#{@bar_bg}]"
set -g @mod_github "#{?#{!=:#(bash $HOME/.tmux_conf/helpers.sh get_github_user_name),},#{E:@_mod_github_body},}"

# current-ssh — reads /tmp/tmux_ssh_hosts_<session>, hidden when empty.
set -g @mod_ssh_bg   "#74c7ec"
set -g @mod_ssh_text "#11111b"
set -g @_mod_ssh_body "#[fg=#{@mod_ssh_bg},bg=#{@bar_bg}]#[fg=#{@mod_ssh_text},bg=#{@mod_ssh_bg},bold] #(cat /tmp/tmux_ssh_hosts_#S 2>/dev/null) #[fg=#{@mod_ssh_bg},bg=#{@bar_bg}]"
set -g @mod_ssh "#{?#{!=:#(cat /tmp/tmux_ssh_hosts_#S 2>/dev/null),},#{E:@_mod_ssh_body},}"

# prefix — visible only while #{client_prefix} is true.
set -g @mod_prefix_bg   "#f38ba8"
set -g @mod_prefix_text "#11111b"
set -g @_mod_prefix_body "#[fg=#{@mod_prefix_bg},bg=#{@bar_bg}]#[fg=#{@mod_prefix_text},bg=#{@mod_prefix_bg},bold] PREFIX #[fg=#{@mod_prefix_bg},bg=#{@bar_bg}]"
set -g @mod_prefix "#{?client_prefix,#{E:@_mod_prefix_body},}"

# zoomed — visible only while #{window_zoomed_flag} is true.
set -g @mod_zoomed_bg   "#fab387"
set -g @mod_zoomed_text "#11111b"
set -g @_mod_zoomed_body "#[fg=#{@mod_zoomed_bg},bg=#{@bar_bg}]#[fg=#{@mod_zoomed_text},bg=#{@mod_zoomed_bg},bold] ZOOMED #[fg=#{@mod_zoomed_bg},bg=#{@bar_bg}]"
set -g @mod_zoomed "#{?window_zoomed_flag,#{E:@_mod_zoomed_body},}"

# synced — visible only while #{pane_synchronized} is true.
set -g @mod_synced_bg   "#f9e2af"
set -g @mod_synced_text "#11111b"
set -g @_mod_synced_body "#[fg=#{@mod_synced_bg},bg=#{@bar_bg}]#[fg=#{@mod_synced_text},bg=#{@mod_synced_bg},bold] SYNCED #[fg=#{@mod_synced_bg},bg=#{@bar_bg}]"
set -g @mod_synced "#{?pane_synchronized,#{E:@_mod_synced_body},}"

set -g status-left "#{E:@mod_session}"
set -g status-right "#{E:@mod_synced}#{E:@mod_zoomed}#{E:@mod_prefix}#{E:@mod_ssh}#{E:@mod_github}#{E:@mod_whoami}"

# ─── WINDOW TABS ────────────────────────────────────────────────────
set -g window-status-current-format "#[fg=#{E:@_d3_active_number_bg},bg=#{@bar_bg}]#[fg=#{@win_active_number_text},bg=#{E:@_d3_active_number_bg},bold]#I #[fg=#{E:@_d3_active_number_bg},bg=#{@win_active_name_bg}]▏#[fg=#{@win_active_name_text},bg=#{@win_active_name_bg}]#W #[fg=#{@win_active_name_bg},bg=#{@bar_bg}]"
set -g window-status-format         "#[fg=#{E:@_d3_inactive_number_bg},bg=#{@bar_bg}]#[fg=#{@win_inactive_number_text},bg=#{E:@_d3_inactive_number_bg}]#I #[fg=#{E:@_d3_inactive_number_bg},bg=#{@win_inactive_name_bg}]▏#[fg=#{@win_inactive_name_text},bg=#{@win_inactive_name_bg}]#W #[fg=#{@win_inactive_name_bg},bg=#{@bar_bg}]"

set -g window-status-separator " "
