local api = vim.api

git_history = function(mode)
	current_line = api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = api.nvim_buf_get_mark(0, '<')
		end_pos = api.nvim_buf_get_mark(0, '>')
	elseif mode == 'n' then
		start_pos = api.nvim_buf_get_mark(0, '[')
		end_pos = api.nvim_buf_get_mark(0, ']')
	end

	start_line = start_pos[1]
	end_line = end_pos[1]

	api.nvim_command('Git log -L' .. start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%'))
end

-- Git submode
local Hydra = require('hydra')
local gitsigns = gs
local hint = [[
 _j_: next hunk   _<C-s>_: stage hunk    _r_: reset hunk
 _k_: prev hunk   _u_: undo stage hunk   _R_: reset buffer
 ^ ^              _S_: stage buffer

 ^ ^                 Conflicts
 _<C-k>_: take upper _<C-j>_: take lower _<C-a>_: take both
 ^
		  _<Enter>_: Fugitive  _<Esc>_: exit
]]
-- _<Enter>_: Fugitive  _<Esc>_: exit  _q_: exit  _<C-c>_: exit
diffview_hydra = Hydra({
	hint = nil,
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
				gitsigns.toggle_linehl(true)
				gitsigns.toggle_deleted(true)
				vim.cmd 'echo'
			end
		end,
		on_exit = function()
			local diff = api.nvim_get_option_value('diff', {})
			if not diff then
				gitsigns.toggle_linehl(false)
				gitsigns.toggle_deleted(false)
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
			-- 	gitsigns.next_hunk({ navigation_message = false })
			-- end
			gitsigns.next_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { expr = true }, },
		{ 'k', function()
			-- TODO: make it move by changes only if there are no hunks
			-- local diff = api.nvim_get_option_value('diff', {})
			-- if diff then
			-- 	api.nvim_feedkeys('[c', 'n', false)
			-- else
			-- 	gitsigns.prev_hunk({ navigation_message = false })
			-- end
			gitsigns.prev_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { expr = true }, },
		{ '<C-s>', function()
			gitsigns.stage_hunk(nil)
			gitsigns.next_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { silent = true }, },
		{ 'r', function()
			gitsigns.reset_hunk(nil)
			gitsigns.next_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { silent = true }, },
		{ 'R', ':Gitsigns reset_buffer<CR>', { silent = true } },
		{ 'u', gitsigns.undo_stage_hunk },
		{ 'S', gitsigns.stage_buffer },
		{ '<C-k>', function()
			actions.conflict_choose('ours')
		end, },
		{ '<C-j>', function()
			actions.conflict_choose('theirs')
		end, },
		{ '<C-a>', function()
			actions.conflict_choose('all')
		end, },
		{ '<Enter>', '<cmd>Git<CR>', { exit = true } },
		-- { 'q', nil, { exit = true, nowait = true } },
		{ '<Esc>', nil, { exit = true, nowait = true } },
	},
})

-- Auto git mode in diff files
api.nvim_create_autocmd('BufEnter', {
	group = config_autocmds,
	pattern = '*',
	callback = function(events)
		local diff = api.nvim_get_option_value('diff', { buf = events.buf })

		if diff and vim.b.git_hydra == nil then
			diffview_hydra:activate()
			vim.b.git_hydra = true -- Turn on git hydra once for each buffer
		end
	end,
})

