-- WezTerm
-- https://wezfurlong.org/wezterm/

local wezterm = require 'wezterm'
local mux = wezterm.mux

-- maximize on startup
wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
    -- Connec to wsl
    default_domain = "WSL:Ubuntu",

    -- No binds, using tmux anyways
    disable_default_key_bindings = false,

    -- No window padding and decorations
    window_decorations = "RESIZE",
    enable_scroll_bar = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    enable_tab_bar = false,

    -- No confirmation for exit
    window_close_confirmation = "NeverPrompt",

    -- Font configuration
    font = wezterm.font('CaskaydiaCove Nerd Font Mono'),
    font_size = 10.5,

    -- Disable ligatures
    -- https://wezfurlong.org/wezterm/config/font-shaping.html
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

    -- Cursor style
    -- default_cursor_style = 'BlinkingBar',

    -- Color scheme
    colors = {
        background = '#000000',
        foreground = '#ffffff',
        cursor_bg = '#ffffff',
        cursor_fg = '#000000',

        ansi = {
            '#2e3436',
            '#cc0000',
            '#4e9a06',
            '#c4a000',
            '#3465a4',
            '#75507b',
            '#06989a',
            '#d3d7cf',
        },
        bright = {
            '#555753',
            '#ef2929',
            '#8ae234',
            '#fce94f',
            '#729fcf',
            '#ad7fa8',
            '#34e2e2',
            '#eeeeec',
        },
    }
}
