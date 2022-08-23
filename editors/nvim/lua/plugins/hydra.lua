local Hydra = require('hydra')
local map = vim.keymap.set
local api = vim.api

-- Window resizer
Hydra({
	hint = [[
 ^^^^    Size
 ^^^^------------- 
 _+_ _-_: height
 _>_ _<_: width
 ^ _=_ ^: equalize
 ^  _<Esc>_
	]],
	config = {
		timeout = 4000,
		hint = {
			border = 'rounded'
		}
	},
	mode = 'n',
	body = '<C-w>',
	heads = {
		-- Size
		{ '+', '<C-w>+' },
		{ '-', '<C-w>-' },
		{ '>', '2<C-w>>', { desc = 'increase width' } },
		{ '<', '2<C-w><', { desc = 'decrease width' } },
		{ '=', '<C-w>=', { exit = true, desc = 'equalize'} },
		--
		{ '<Esc>', nil,  { exit = true }}
	}
})

-- Git submode
local gitsigns = require('gitsigns')
local hint = [[
 _j_: next hunk   _s_: stage hunk        _r_: reset hunk     _d_: show deleted   _b_: blame line
 _k_: prev hunk   _u_: undo stage hunk   _R_: reset buffer   _p_: preview hunk   _B_: blame show full
 ^ ^                  _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^				_<Enter>_: Fugitive       _<Esc>_: exit       _q_: exit
]]

Hydra({
	hint = hint,
	config = {
		color = 'pink',
		invoke_on_body = true,
		hint = {
			position = 'bottom',
			border = 'rounded'
		},
		on_enter = function()
			-- vim.bo.modifiable = false
			-- gitsigns.toggle_signs(true)
			gitsigns.toggle_linehl(true)
			gitsigns.toggle_deleted(true)
			-- Go to first hunk
			api.nvim_feedkeys('gg]c', 'm', false)
			center_screen()
		end,
		on_exit = function()
			-- gitsigns.toggle_signs(true)
			gitsigns.toggle_linehl(false)
			gitsigns.toggle_deleted(false)
			vim.cmd 'echo' -- clear the echo area
		end
	},
	mode = {'n','x'},
	body = '<leader>gg',
	heads = {
		{ 'j', function()
			gitsigns.next_hunk()
			center_screen()
		end, { expr = true } },
		{ 'k', function()
			gitsigns.prev_hunk()
			center_screen()
		end, { expr = true } },
		{ 's', function()
			gitsigns.stage_hunk(nil)
			gitsigns.next_hunk()
			center_screen()
		end, { silent = true } },
		{ 'r', function()
			gitsigns.reset_hunk(nil)
			gitsigns.next_hunk()
			center_screen()
		end, { silent = true } },
		{ 'R', ':Gitsigns reset_buffer<CR>', { silent = true } },
		{ 'u', gitsigns.undo_stage_hunk },
		{ 'S', gitsigns.stage_buffer },
		{ 'p', gitsigns.preview_hunk },
		{ 'd', gitsigns.toggle_deleted, { nowait = true } },
		{ 'b', gitsigns.blame_line },
		{ 'B', function() gitsigns.blame_line{ full = true } end },
		{ '/', gitsigns.show, { exit = true } }, -- show the base of the file
		{ '<Enter>', '<cmd>Git<CR>', { exit = true } },
		{ 'q', nil, { exit = true, nowait = true } },
		{ '<Esc>', nil, { exit = true, nowait = true } },
	}
})

-- Draw boxes and arrows (venn.nvim)
hint = [[
^^^^    Draw
^^^^-------------
Arrows: _<C-h>_ _<C-j>_ _<C-k>_ _<C-l>_
Box (select box with visual block first): _<C-f>_
^ ^				_<Esc>_: exit
]]

Hydra({
	name = 'Draw',
	hint = hint,
	config = {
		color = 'pink',
		invoke_on_body = true,
		hint = {
			position = 'bottom',
			border = 'rounded'
		},
		on_enter = function()
			vim.o.virtualedit = 'all'
		end,
	},
	mode = {'n'},
	body = '<leader>draw',
	heads = {
		{ '<C-h>', '<C-v>h:VBox<CR>' },
		{ '<C-j>', '<C-v>j:VBox<CR>' },
		{ '<C-k>', '<C-v>k:VBox<CR>' },
		{ '<C-l>', '<C-v>l:VBox<CR>' },
		{ '<C-f>', ':VBox<CR>', { mode = 'v' }},
		{ '<Esc>', nil, { exit = true, nowait = true } },
	}
})


local ts_move = require'nvim-treesitter.textobjects.move'
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
		}
	},
	mode = {'n', 'x'},
	heads = {
		{ 'j', function ()
			ts_move.goto_next_start('@function.outer')
			center_screen()
		end },
		{ 'J', function ()
			ts_move.goto_next_end('@function.outer')
			center_screen()
		end },
		{ 'k', function ()
			ts_move.goto_previous_start('@function.outer')
			center_screen()
		end },
		{ 'K', function ()
			ts_move.goto_previous_end('@function.outer')
			center_screen()
		end },
		--
		{ '<Esc>', nil,  { exit = true }}
	}
})
map({'n', 'x'}, 'gj', function ()
	ts_move.goto_next_start('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gj', function () ts_move.goto_next_start('@function.outer') end)

map({'n', 'x'}, 'gk', function ()
	ts_move.goto_previous_start('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gk', function () ts_move.goto_previous_start('@function.outer') end)

map({'n', 'x'}, 'gJ', function ()
	ts_move.goto_next_end('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gJ', function () ts_move.goto_next_end('@function.outer') end)

map({'n', 'x'}, 'gK', function ()
	ts_move.goto_previous_end('@function.outer')
	center_screen()
	move_funcs:activate()
end)
map('o', 'gK', function () ts_move.goto_previous_end('@function.outer') end)

-- Spell fixing quickly
local telescope_builtin = require('telescope.builtin')
Hydra({
	hint = [[
 _j_: Next _k_: Prev
 _<Enter>_: Suggest Fix

  _<Esc>_ quit _q_ quit
	]],
	config = {
		color = 'pink',
		timeout = 10000,
		invoke_on_body = true,
		hint = {
			border = 'rounded'
		},
		on_enter = function()
			vim.opt.spell = true
		end,
		on_exit = function()
			vim.opt.spell = false
		end
	},
	mode = 'n',
	body = '<leader>ss',
	heads = {
		{ 'j', function ()
			api.nvim_input(']s')
			center_screen()
		end },
		{ 'k', function ()
			api.nvim_input('[s')
			center_screen()
		end },
		{ '<Enter>', function ()
			telescope_builtin.spell_suggest()
		end },
		--
		{ '<Esc>', nil,  { exit = true, nowait = true }},
		{ 'q', nil,  { exit = true, nowait = true }},
	}
})
