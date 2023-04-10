local M = {}

local api = vim.api

local hint = [[
 _j_: next hunk   _<C-s>_: stage hunk    _r_: reset hunk
 _k_: prev hunk   _u_: undo stage hunk   _R_: reset buffer
 ^ ^              _S_: stage buffer

 ^ ^                 Conflicts
 _<C-k>_: take upper _<C-j>_: take lower _<C-a>_: take both
 ^
		  _<Enter>_: Fugitive  _<Esc>_: exit
]]

HYDRAS['diff_viewer'] = {
	hint = hint,
	config = {
		color = 'pink',
		invoke_on_body = true,
		hint = {
			position = 'bottom',
			border = 'rounded'
		},
		on_enter = function()
			local diff = api.nvim_get_option_value('diff', {})
			if not diff then
				require('gitsigns').toggle_linehl(true)
				require('gitsigns').toggle_deleted(true)
				vim.cmd 'echo'
			end
		end,
		on_exit = function()
			local diff = api.nvim_get_option_value('diff', {})
			if not diff then
				require('gitsigns').toggle_linehl(false)
				require('gitsigns').toggle_deleted(false)
				vim.cmd 'echo'
			end
		end,
	},
	mode = { 'n', 'x' },
	body = '<leader>gg',
	heads = {
		{ 'j', function()
			-- TODO: make it move by changes only if there are no hunks
			-- local diff = api.nvim_get_option_value('diff', {})
			-- if diff then
			-- 	api.nvim_feedkeys(']c', 'n', false)
			-- else
			-- 	require('gitsigns').next_hunk({ navigation_message = false })
			-- end
			require('gitsigns').next_hunk({ navigation_message = false })
			require('utils.misc').center_screen()
			return '<Ignore>'
		end, { expr = true }, },
		{ 'k', function()
			-- TODO: make it move by changes only if there are no hunks
			-- local diff = api.nvim_get_option_value('diff', {})
			-- if diff then
			-- 	api.nvim_feedkeys('[c', 'n', false)
			-- else
			-- 	require('gitsigns').prev_hunk({ navigation_message = false })
			-- end
			require('gitsigns').prev_hunk({ navigation_message = false })
			require('utils.misc').center_screen()
			return '<Ignore>'
		end, { expr = true }, },
		{ '<C-s>', function()
			require('gitsigns').stage_hunk(nil)
			require('gitsigns').next_hunk({ navigation_message = false })
			require('utils.misc').center_screen()
			return '<Ignore>'
		end, { silent = true }, },
		{ 'r', function()
			require('gitsigns').reset_hunk(nil)
			require('gitsigns').next_hunk({ navigation_message = false })
			require('utils.misc').center_screen()
			return '<Ignore>'
		end, { silent = true }, },
		{ 'R', ':Gitsigns reset_buffer<CR>', { silent = true } },
		{ 'u', function() require('gitsigns').undo_stage_hunk() end },
		{ 'S', function() require('gitsigns').stage_buffer() end },
		{ '<C-k>', function()
			require('diffview.actions').conflict_choose('ours')
		end, },
		{ '<C-j>', function()
			require('diffview.actions').conflict_choose('theirs')
		end, },
		{ '<C-a>', function()
			require('diffview.actions').conflict_choose('all')
		end, },
		{ '<Enter>', '<cmd>Git<CR>', { exit = true } },
		-- { 'q', nil, { exit = true, nowait = true } },
		{ '<Esc>', nil, { exit = true, nowait = true } },
	},
}

return M
