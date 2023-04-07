if vim.g.started_by_firenvim then
	do return end
end

-- anuvyklack/hydra.nvim
local Hydra = require('hydra')
local map = vim.keymap.set
local api = vim.api

local ts_move = require 'nvim-treesitter.textobjects.move'
-- Move up/down functions
local move_funcs = Hydra({
	hint = [[
 _j_ _J_ : up
 _k_ _K_ : down
  _<Esc>_
	]],
	config = {
		timeout = 4000,
		hint = {
			border = 'rounded'
		},
	},
	mode = { 'n', 'x' },
	heads = {
		{ 'j', function()
			ts_move.goto_next_start('@function.name')
			center_screen()
		end, },
		{ 'J', function()
			ts_move.goto_next_end('@function.outer')
			center_screen()
		end, },
		{ 'k', function()
			ts_move.goto_previous_start('@function.name')
			center_screen()
		end, },
		{ 'K', function()
			ts_move.goto_previous_end('@function.outer')
			center_screen()
		end, },
		--
		{ '<Esc>', nil, { exit = true } },
	},
})
map({ 'n', 'x' }, 'gj', function()
	ts_move.goto_next_start('@function.name')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gj', function() ts_move.goto_next_start('@function.name') end)

map({ 'n', 'x' }, 'gk', function()
	ts_move.goto_previous_start('@function.name')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gk', function() ts_move.goto_previous_start('@function.name') end)

map({ 'n', 'x' }, 'gJ', function()
	ts_move.goto_next_end('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gJ', function() ts_move.goto_next_end('@function.outer') end)

map({ 'n', 'x' }, 'gK', function()
	ts_move.goto_previous_end('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gK', function() ts_move.goto_previous_end('@function.outer') end)

