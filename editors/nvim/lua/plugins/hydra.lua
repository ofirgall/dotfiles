local Hydra = require('hydra')

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
 _<C-j>_: next hunk   _s_: stage hunk        _r_: reset hunk     _d_: show deleted   _b_: blame line
 _<C-k>_: prev hunk   _u_: undo stage hunk   _R_: reset buffer   _p_: preview hunk   _B_: blame show full
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
		{ '<C-j>', function()
			if vim.wo.diff then return ']czz' end
			vim.schedule(function()
				gitsigns.next_hunk()
				vim.api.nvim_feedkeys('zz', '', false)
			end)
			return '<Ignore>'
		end, { expr = true } },
		{ '<C-k>', function()
			if vim.wo.diff then return '[czz' end
			vim.schedule(function()
				gitsigns.prev_hunk()
				vim.api.nvim_feedkeys('zz', '', false)
			end)
			return '<Ignore>'
		end, { expr = true } },
		{ 's', ':Gitsigns stage_hunk<CR>', { silent = true } },
		{ 'r', ':Gitsigns reset_hunk<CR>', { silent = true } },
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
			vim.opt_local.virtualedit = 'all'
		end,
		on_exit = function()
			vim.opt_local.virtualedit = ''
		end
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
