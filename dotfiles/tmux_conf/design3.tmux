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
# joined by a sharp vertical color change (no seam glyph):
#
#   <L> #I [color shift] #W <R>
#
#   <L>  outer left cap   number_bg → bar_bg   (so the bubble's left
#                                              rounded edge belongs to
#                                              the number section)
#    #I  number cell      number_text on number_bg
#        sharp seam: bg switches from number_bg to name_bg
#    #W  name cell        name_text on name_bg
#   <R>  outer right cap  name_bg → bar_bg
#
# Cap glyphs (U+E0B6 / U+E0B4) inlined as literal bytes — see bug above.
# Hollowed-edges variant for future use:  /  ‌

### COLORS (placeholder — proper palette in Step 6) ###
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


# Resolved number-circle bg — per-window @window_color wins, theme
# default otherwise. Active uses @window_color_active (defaults to
# @window_color) so the user can optionally pick a dimmer shade for
# active windows; same lookup pattern for inactive.
set -g @window_color ""
set -g @window_color_active ""
set -g @_d3_active_number_bg   "#{?#{!=:#{@window_color_active},},#{@window_color_active},#{?#{!=:#{@window_color},},#{@window_color},#{@win_active_number_bg}}}"
set -g @_d3_inactive_number_bg "#{?#{!=:#{@window_color},},#{@window_color},#{@win_inactive_number_bg}}"

### STATUS BAR ###
set -g status-style "bg=#{@bar_bg},fg=#cdd6f4"
set -g status-justify "left"

# Test pill kept from Step 2.
set -g status-left "#[fg=#{@pill_bg},bg=#{@bar_bg}]#[fg=#{@pill_text},bg=#{@pill_bg},bold] hello #[fg=#{@pill_bg},bg=#{@bar_bg}]"
set -g status-right ""

# ─── WINDOW TABS: one bubble, two color sections, sharp seam ───────
set -g window-status-current-format "#[fg=#{E:@_d3_active_number_bg},bg=#{@bar_bg}]#[fg=#{@win_active_number_text},bg=#{E:@_d3_active_number_bg},bold]#I #[fg=#{E:@_d3_active_number_bg},bg=#{@win_active_name_bg}]▏#[fg=#{@win_active_name_text},bg=#{@win_active_name_bg}]#W #[fg=#{@win_active_name_bg},bg=#{@bar_bg}]"
set -g window-status-format         "#[fg=#{E:@_d3_inactive_number_bg},bg=#{@bar_bg}]#[fg=#{@win_inactive_number_text},bg=#{E:@_d3_inactive_number_bg}]#I #[fg=#{E:@_d3_inactive_number_bg},bg=#{@win_inactive_name_bg}]▏#[fg=#{@win_inactive_name_text},bg=#{@win_inactive_name_bg}]#W #[fg=#{@win_inactive_name_bg},bg=#{@bar_bg}]"

set -g window-status-separator " "
