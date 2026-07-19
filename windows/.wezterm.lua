local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

local keys = {
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'F5', mods = 'SUPER', action = act.ResetFontSize },
  { key = 'F6', mods = 'SUPER', action = act.ReloadConfiguration },
  { key = 'F12', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
  { key = 'Tab', mods = 'CTRL', action = act.SendString '\x1b[27;5;9~' },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;6;9~' },
  { key = ',', mods = 'CTRL', action = act.SendString '\x1b[27;5;44~' },
  { key = '.', mods = 'CTRL', action = act.SendString '\x1b[27;5;46~' },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.SendString '\x1bJ' },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.SendString '\x1bH' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.SendString '\x1bK' },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.SendString '\x1bL' },
  { key = ',', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;5;60~' },
  { key = '.', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;5;62~' },
  { key = ',', mods = 'ALT|SHIFT', action = act.SendString '\x1b[27;3;60~' },
  { key = '.', mods = 'ALT|SHIFT', action = act.SendString '\x1b[27;3;62~' },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b[13;2u' },
  { key = 'Enter', mods = 'CTRL', action = act.SendString '\x1b[13;5u' },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.ToggleFullScreen },
  { key = ';', mods = 'CTRL', action = act.SendString '\x1b;' },
  { key = ' ', mods = 'SHIFT', action = act.SendString '\x1b[27;2;32~' },
  { key = ' ', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;6;32~' },
  { key = '1', mods = 'CTRL', action = act.SendString '\x1b[49;5u' },
  { key = '2', mods = 'CTRL', action = act.SendString '\x1b[50;5u' },
  { key = '3', mods = 'CTRL', action = act.SendString '\x1b[51;5u' },
  { key = '4', mods = 'CTRL', action = act.SendString '\x1b[52;5u' },
  { key = '5', mods = 'CTRL', action = act.SendString '\x1b[53;5u' },
  { key = '6', mods = 'CTRL', action = act.SendString '\x1b[54;5u' },
  { key = '7', mods = 'CTRL', action = act.SendString '\x1b[55;5u' },
  { key = '8', mods = 'CTRL', action = act.SendString '\x1b[56;5u' },
  { key = '9', mods = 'CTRL', action = act.SendString '\x1b[57;5u' },
  { key = '0', mods = 'CTRL', action = act.SendString '\x1b[48;5u' },
}

-- Alt+key: send ESC+key as single atomic string (not SendKey which splits across writes)
for i = string.byte('a'), string.byte('z') do
  local c = string.char(i)
  table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
  table.insert(keys, { key = c, mods = 'ALT|SHIFT', action = act.SendString('\x1b' .. string.upper(c)) })
end

for _, c in ipairs({ '0','1','2','3','4','5','6','7','8','9' }) do
  table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
end

for _, c in ipairs({ '-', '=', '`', ',', '.', '/', ';' }) do
  table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
end

for _, c in ipairs({ '!', '@', '#', '$', '%', '^', '&', '*', '(', ')' }) do
  table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
end

return {
  default_prog = { 'C:/msys64/usr/bin/env.exe', 'MSYSTEM=UCRT64', '/usr/bin/zsh.exe' },

  disable_default_key_bindings = true,
  keys = keys,

  window_decorations = "RESIZE",
  enable_scroll_bar = false,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  enable_tab_bar = false,

  window_close_confirmation = "NeverPrompt",

  font = wezterm.font('CaskaydiaCove NFM'),
  font_size = 12,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },

  use_ime = false,
  use_dead_keys = false,
  hide_mouse_cursor_when_typing = true,

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
    brights = {
      '#555753',
      '#ef2929',
      '#8ae234',
      '#fce94f',
      '#729fcf',
      '#ad7fa8',
      '#34e2e2',
      '#eeeeec',
    },
  },
}
