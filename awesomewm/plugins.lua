-- intrntbrn/awesomewm-vim-tmux-navigator
require("awesomewm-vim-tmux-navigator") {
    up = { "Up", "k" },
    down = { "Down", "j" },
    left = { "Left", "h" },
    right = { "Right", "l" },
    mod = "Mod1", -- Alt
    mod_keysym = "Alt_L",
}

-- intrntbrn/smart_borders
local awful = require("awful")
require('smart_borders') {
    show_button_tooltips = true,
    button_left_click = function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end,
    right_click = function(c)
        if c.maximized then
            c.maximized = false
        end
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end
}
