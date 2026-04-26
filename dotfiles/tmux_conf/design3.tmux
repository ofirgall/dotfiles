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
# GLYPHS — single source of truth
# ─────────────────────────────────────────────────────────────────────
# Powerline-extra glyphs render fine when referenced via #{@option}
# inside status-line formats. Earlier in this rewrite we thought a tmux
# bug stripped them; turned out terminal rendering was hiding them in
# bracketed display-message output (the glyph IS in the byte stream).
#
# Default rounded:        @cap_l + @cap_r       U+E0B6 / U+E0B4
# Hollowed-edges variant: @cap_l_alt + @cap_r_alt  U+E0B5 / U+E0B7
# Thin seam (window tab): @seam                  U+258F
set -g @cap_l ""
set -g @cap_r ""
set -g @cap_l_alt ""
set -g @cap_r_alt ""
set -g @seam "▏"
# ─────────────────────────────────────────────────────────────────────

# Pane bg — explicitly unset so a reload restores tmux default
# (terminal bg). Otherwise an old `bg=…` value from a prior reload
# would persist.
set -u window-style
set -u window-active-style

# ─────────────────────────────────────────────────────────────────────
# PALETTE — single source of truth for every color used below.
# ─────────────────────────────────────────────────────────────────────
# To recolor design3 (or swap themes): change values in this block.
# Every role/module assignment downstream is `set -gF "#{@c_X}"` so
# the palette references resolve at set time and downstream lookups
# return literal hex.
set -g @c_bar_bg       "#051829"  ;# status bar background
set -g @c_text_dark    "#11111b"  ;# text on bright bubbles (number circle, ssh, prefix, zoomed, synced, suspended)
set -g @c_text_light   "#d9e6fa"  ;# bar fg + text on dark bubbles (session, github, active-window name)
set -g @c_text_dim     "#94d0fe"  ;# (unused — was inactive name text before the inactive-palette refactor)
set -g @c_surface      "#22385c"  ;# session, github, active-window name pill bg
set -g @c_surface_dim  "#2c4a73"  ;# (unused — was inactive number bg before refactor)
set -g @c_blue_strong  "#1ca0fd"  ;# (unused — was github bg before it was unified with session)
set -g @c_blue_mid     "#58b8fd"  ;# ssh bubble bg
set -g @c_blue_light   "#94d0fe"  ;# active window number circle bg
set -g @c_red          "#ff7979"  ;# prefix + suspended bubble bg
set -g @c_peach        "#f8b471"  ;# zoomed bubble bg
set -g @c_yellow       "#f0e68c"  ;# synced bubble bg

# Inactive window tab — darker bg + dim text, distinct from the bright
# `@c_surface` used by active tabs / modules.
set -g @c_inactive_bg     "#0f253e"  ;# inactive window name pill bg
set -g @c_inactive_bg_dim "#1b3858"  ;# inactive window number circle bg
set -g @c_inactive_text   "#c4c6cc"  ;# inactive window text (both number and name)

### ROLES ###
# Bar.
set -gF @bar_bg "#{@c_bar_bg}"

# Window tabs.
set -gF @win_active_number_bg     "#{@c_blue_light}"
set -gF @win_active_number_text   "#{@c_text_dark}"
set -gF @win_active_name_bg       "#{@c_surface}"
set -gF @win_active_name_text     "#{@c_text_light}"
set -gF @win_inactive_number_bg   "#{@c_inactive_bg_dim}"
set -gF @win_inactive_number_text "#{@c_inactive_text}"
set -gF @win_inactive_name_bg     "#{@c_inactive_bg}"
set -gF @win_inactive_name_text   "#{@c_inactive_text}"


# Resolved number-circle bg per state.
#   @window_color      = bright accent (used when window is ACTIVE)
#   @window_color_dim  = 50%-dim variant (used when window is INACTIVE)
# @window_color_dim is auto-derived from @window_color by hooks.tmux.
set -g @window_color ""
set -g @window_color_dim ""
set -g @_d3_active_number_bg   "#{?#{!=:#{@window_color},},#{@window_color},#{@win_active_number_bg}}"
set -g @_d3_inactive_number_bg "#{?#{!=:#{@window_color_dim},},#{@window_color_dim},#{?#{!=:#{@window_color},},#{@window_color},#{@win_inactive_number_bg}}}"

### STATUS BAR ###
set -gF status-style "bg=#{@c_bar_bg},fg=#{@c_text_light}"
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
set -gF @mod_session_bg   "#{@c_surface}"
set -gF @mod_session_text "#{@c_text_light}"
set -g @mod_session "#[fg=#{@mod_session_text},bg=#{@mod_session_bg},bold] #{=35:#{s/^drift-chore-//:session_name}}#[fg=#{@mod_session_bg},bg=#{@bar_bg}]#{@cap_r}"


# github — current authenticated github account, hidden when empty.
# Body is in @_mod_github_body so the comma-laden #[bg=X,fg=Y]
# directives don't collide with the #{?cond,then,else} parser.
set -gF @mod_github_bg   "#{@c_surface}"
set -gF @mod_github_text "#{@c_text_light}"
set -g @_mod_github_body "#[fg=#{@mod_github_bg}]#{@cap_l}#[fg=#{@mod_github_text},bg=#{@mod_github_bg},bold] #(bash $HOME/.tmux_conf/helpers.sh get_github_user_name) "
set -g @mod_github "#{?#{!=:#(bash $HOME/.tmux_conf/helpers.sh get_github_user_name),},#{E:@_mod_github_body},}"

# current-ssh — reads /tmp/tmux_ssh_hosts_<session>, hidden when empty.
set -gF @mod_ssh_bg   "#{@c_blue_mid}"
set -gF @mod_ssh_text "#{@c_text_dark}"
set -g @_mod_ssh_body "#[fg=#{@mod_ssh_bg}]#{@cap_l}#[fg=#{@mod_ssh_text},bg=#{@mod_ssh_bg},bold]#(cat /tmp/tmux_ssh_hosts_#S 2>/dev/null) "
set -g @mod_ssh "#{?#{!=:#(cat /tmp/tmux_ssh_hosts_#S 2>/dev/null),},#{E:@_mod_ssh_body},}"

# prefix — visible only while #{client_prefix} is true.
set -gF @mod_prefix_bg   "#{@c_red}"
set -gF @mod_prefix_text "#{@c_text_dark}"
set -g @_mod_prefix_body "#[fg=#{@mod_prefix_bg}]#{@cap_l}#[fg=#{@mod_prefix_text},bg=#{@mod_prefix_bg},bold]PREFIX "
set -g @mod_prefix "#{?client_prefix,#{E:@_mod_prefix_body},}"

# zoomed — visible only while #{window_zoomed_flag} is true.
set -gF @mod_zoomed_bg   "#{@c_peach}"
set -gF @mod_zoomed_text "#{@c_text_dark}"
set -g @_mod_zoomed_body "#[fg=#{@mod_zoomed_bg}]#{@cap_l}#[fg=#{@mod_zoomed_text},bg=#{@mod_zoomed_bg},bold]ZOOMED "
set -g @mod_zoomed "#{?window_zoomed_flag,#{E:@_mod_zoomed_body},}"

# synced — visible only while #{pane_synchronized} is true.
set -gF @mod_synced_bg   "#{@c_yellow}"
set -gF @mod_synced_text "#{@c_text_dark}"
set -g @_mod_synced_body "#[fg=#{@mod_synced_bg}]#{@cap_l}#[fg=#{@mod_synced_text},bg=#{@mod_synced_bg},bold]SYNCED "
set -g @mod_synced "#{?pane_synchronized,#{E:@_mod_synced_body},}"

# suspended — visible only while #{@suspended_mode} is set (by
# tmux-suspend's @suspend_on_suspend_command).
set -gF @mod_suspended_bg   "#{@c_red}"
set -gF @mod_suspended_text "#{@c_text_dark}"
set -g @_mod_suspended_body "#[fg=#{@mod_suspended_bg}]#{@cap_l}#[fg=#{@mod_suspended_text},bg=#{@mod_suspended_bg},bold]SUSPENDED "
set -g @mod_suspended "#{?#{@suspended_mode},#{E:@_mod_suspended_body},}"

set -g status-left "#{E:@mod_session} "
set -g status-right "#{E:@mod_suspended}#{E:@mod_synced}#{E:@mod_zoomed}#{E:@mod_prefix}#{E:@mod_ssh}#{E:@mod_github}"

# ─── WINDOW TABS ────────────────────────────────────────────────────
set -g window-status-current-format "#[fg=#{E:@_d3_active_number_bg},bg=#{@bar_bg}]#{@cap_l}#[fg=#{@win_active_number_text},bg=#{E:@_d3_active_number_bg},bold]#I #[fg=#{E:@_d3_active_number_bg},bg=#{@win_active_name_bg}]#{@seam}#[fg=#{@win_active_name_text},bg=#{@win_active_name_bg}]#W #[fg=#{@win_active_name_bg},bg=#{@bar_bg}]#{@cap_r}"
set -g window-status-format         "#[fg=#{E:@_d3_inactive_number_bg},bg=#{@bar_bg}]#{@cap_l}#[fg=#{@win_inactive_number_text},bg=#{E:@_d3_inactive_number_bg}]#I #[fg=#{E:@_d3_inactive_number_bg},bg=#{@win_inactive_name_bg}]#{@seam}#[fg=#{@win_inactive_name_text},bg=#{@win_inactive_name_bg}]#W #[fg=#{@win_inactive_name_bg},bg=#{@bar_bg}]#{@cap_r}"

set -g window-status-separator " "

### POLISH ###
# Pane borders + copy-mode selection — colors taken from design.tmux.
set -g pane-border-style        "fg=#1865b5"
set -g pane-active-border-style "fg=#44475a"
set -g mode-style               "bg=#27406b,fg=#ffffff"

# message-style left at tmux default (design.tmux didn't override it).
set -u message-style
set -u message-command-style

### SUSPENDED MODE ###
# tmux-suspend toggles @suspended_mode; the @mod_suspended module
# (defined above) shows a red SUSPENDED bubble when it's set.
set -g @suspend_on_suspend_command "tmux set -g @suspended_mode 1 \\; refresh-client -S"
set -g @suspend_on_resume_command  "tmux set -ug @suspended_mode \\; refresh-client -S"
