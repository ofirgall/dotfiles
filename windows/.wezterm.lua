local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

local function is_nvim(pane)
  local proc = pane:get_foreground_process_name()
  if proc then
    local name = proc:match('[^/\\]+$') or ''
    return name:find('nvim') ~= nil or name:find('kv') ~= nil
  end
  return false
end

local function conditional(terminal_action, escape_seq)
  return wezterm.action_callback(function(window, pane)
    if is_nvim(pane) then
      window:perform_action(act.SendString(escape_seq), pane)
    else
      window:perform_action(terminal_action, pane)
    end
  end)
end

-- Keys used for terminal management (excluded from Alt pass-through loops)
local terminal_alt_keys = { e=true, o=true, t=true, w=true, q=true, z=true, c=true }
local terminal_alt_shift_keys = { H=true, J=true, K=true, L=true, W=true, Q=true, T=true }
local terminal_alt_digits = { ['1']=true, ['2']=true, ['3']=true, ['4']=true, ['5']=true,
                              ['6']=true, ['7']=true, ['8']=true, ['9']=true, ['0']=true }
local terminal_alt_punct = { [',']=true, ['.']=true, ['-']=true, ['`']=true, ['=']=true }

local keys = {
  -- Clipboard
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- Meta
  { key = 'F5', mods = 'SUPER', action = act.ResetFontSize },
  { key = 'F6', mods = 'SUPER', action = act.ReloadConfiguration },
  { key = 'F12', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.ToggleFullScreen },

  -- === Tabs (always terminal, mirrors tmux Alt+1-9 window select) ===
  { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
  { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
  { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
  { key = '9', mods = 'ALT', action = act.ActivateTab(8) },
  { key = '0', mods = 'ALT', action = act.ActivateTab(9) },
  { key = ',', mods = 'ALT', action = act.ActivateTabRelative(-1) },
  { key = '.', mods = 'ALT', action = act.ActivateTabRelative(1) },
  { key = '-', mods = 'ALT', action = act.ActivateLastTab },
  { key = '`', mods = 'ALT', action = act.ActivateLastTab },
  { key = '=', mods = 'ALT', action = act.ActivateLastTab },
  { key = ',', mods = 'ALT|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '.', mods = 'ALT|SHIFT', action = act.MoveTabRelative(1) },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateLastTab },

  -- === Conditional: terminal action when in shell, pass-through when in nvim ===
  { key = 'e', mods = 'ALT', action = conditional(
      act.SplitHorizontal { domain = 'CurrentPaneDomain' }, '\x1be') },
  { key = 'o', mods = 'ALT', action = conditional(
      act.SplitVertical { domain = 'CurrentPaneDomain' }, '\x1bo') },
  { key = 't', mods = 'ALT', action = conditional(
      act.SpawnTab 'CurrentPaneDomain', '\x1bt') },
  { key = 'w', mods = 'ALT', action = conditional(
      act.CloseCurrentPane { confirm = false }, '\x1bw') },
  { key = 'q', mods = 'ALT', action = conditional(
      act.CloseCurrentPane { confirm = false }, '\x1bq') },
  { key = 'z', mods = 'ALT', action = conditional(
      act.TogglePaneZoomState, '\x1bz') },
  { key = 'c', mods = 'ALT', action = conditional(
      act.ActivateCopyMode, '\x1bc') },

  -- === Pane navigation (conditional: navigate terminal panes in shell, pass to nvim) ===
  { key = 'h', mods = 'CTRL', action = conditional(
      act.ActivatePaneDirection 'Left', '\x08') },    -- \x08 = Ctrl+H
  { key = 'j', mods = 'CTRL', action = conditional(
      act.ActivatePaneDirection 'Down', '\x0a') },    -- \x0a = Ctrl+J
  { key = 'k', mods = 'CTRL', action = conditional(
      act.ActivatePaneDirection 'Up', '\x0b') },      -- \x0b = Ctrl+K
  { key = 'l', mods = 'CTRL', action = conditional(
      act.ActivatePaneDirection 'Right', '\x0c') },   -- \x0c = Ctrl+L

  -- Force pane navigation (always terminal, bypasses nvim)
  { key = 'H', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'J', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'K', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'L', mods = 'ALT|SHIFT', action = act.ActivatePaneDirection 'Right' },

  -- Force close window (always terminal)
  { key = 'W', mods = 'ALT|SHIFT', action = act.CloseCurrentTab { confirm = false } },
  { key = 'Q', mods = 'ALT|SHIFT', action = act.CloseCurrentTab { confirm = false } },

  -- Force new tab (always terminal)
  { key = 'T', mods = 'ALT|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },

  -- === Escape sequences for nvim (not used for terminal management) ===
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;6;9~' },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.SendString '\x1bJ' },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.SendString '\x1bH' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.SendString '\x1bK' },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.SendString '\x1bL' },
  { key = ',', mods = 'CTRL', action = act.SendString '\x1b[27;5;44~' },
  { key = '.', mods = 'CTRL', action = act.SendString '\x1b[27;5;46~' },
  { key = ',', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;5;60~' },
  { key = '.', mods = 'CTRL|SHIFT', action = act.SendString '\x1b[27;5;62~' },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b[13;2u' },
  { key = 'Enter', mods = 'CTRL', action = act.SendString '\x1b[13;5u' },
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

-- Leader key for resize (mirrors tmux prefix + Ctrl+hjkl)
local leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

local leader_keys = {
  { key = 'h', mods = 'CTRL', action = act.AdjustPaneSize { 'Left', 3 } },
  { key = 'j', mods = 'CTRL', action = act.AdjustPaneSize { 'Down', 3 } },
  { key = 'k', mods = 'CTRL', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'l', mods = 'CTRL', action = act.AdjustPaneSize { 'Right', 3 } },
  { key = 'H', mods = 'SHIFT', action = act.AdjustPaneSize { 'Left', 3 } },
  { key = 'J', mods = 'SHIFT', action = act.AdjustPaneSize { 'Down', 3 } },
  { key = 'K', mods = 'SHIFT', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'L', mods = 'SHIFT', action = act.AdjustPaneSize { 'Right', 3 } },
  { key = 'r', action = act.ReloadConfiguration },
}

-- Alt+key: send ESC+key for remaining letters not used by terminal management
for i = string.byte('a'), string.byte('z') do
  local c = string.char(i)
  if not terminal_alt_keys[c] then
    table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
  end
  local C = string.upper(c)
  if not terminal_alt_shift_keys[C] then
    table.insert(keys, { key = c, mods = 'ALT|SHIFT', action = act.SendString('\x1b' .. C) })
  end
end

-- Alt+digit escape sequences for digits not used for tab switching (none — all 0-9 are tabs)
-- Alt+punctuation escape sequences for keys not used for tab navigation
for _, c in ipairs({ '-', '=', '`', ',', '.', '/', ';' }) do
  if not terminal_alt_punct[c] then
    table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
  end
end

-- Alt+Shift+punctuation that aren't tab management
for _, c in ipairs({ '!', '@', '#', '$', '%', '^', '&', '*', '(', ')' }) do
  table.insert(keys, { key = c, mods = 'ALT', action = act.SendString('\x1b' .. c) })
end

return {
  default_prog = { 'pwsh' },

  disable_default_key_bindings = true,
  leader = leader,
  keys = keys,
  key_tables = { leader = leader_keys },

  window_decorations = "RESIZE",
  enable_scroll_bar = false,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  hide_tab_bar_if_only_one_tab = true,

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
