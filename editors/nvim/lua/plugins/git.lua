local api = vim.api

-- lewis6991/gitsigns.nvim
local gs = require('gitsigns')
gs.setup {
	sign_priority = 9,
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or { silent = true }
			map_buffer(bufnr, mode, l, r, '', opts)
		end

		-- Navigation
		map('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(function() gs.next_hunk({ navigation_message = false }) end)
			return '<Ignore>'
		end, { expr = true })

		map('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(function() gs.prev_hunk({ navigation_message = false }) end)
			return '<Ignore>'
		end, { expr = true })
		-- Actions
		map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
		map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
		map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
		map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
		map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
		map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
		map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
		map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns toggle_deleted<CR>')
		-- Text object
		map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end
}

-- sindrets/diffview.nvim
local cb = require 'diffview.config'.diffview_callback
local actions = require('diffview.actions')
require('diffview').setup {
	watch_index = false,
	file_history_panel = {
		log_options = {
			git = {
				single_file = {
					follow = true,
				}
			}
		},
	},
	key_bindings = {
		view = {
			['q']          = '<cmd>:DiffviewClose<cr>',
			['<M-n>']      = actions.focus_files,
			['<M-m>']      = actions.toggle_files,
			['<leader>ck'] = actions.conflict_choose('ours'),
			['<leader>cj'] = actions.conflict_choose('theirs'),
			['<tab>']      = function()
				actions.select_next_entry()
				actions.refresh_files()
			end,
			['<s-tab>']    = function()
				actions.select_prev_entry()
				actions.refresh_files()
			end,

		},
		file_panel = {
			['s'] = cb('toggle_stage_entry'),
			['q'] = cb('close'),
			['gf'] = cb('goto_file_edit'),
			['<M-n>'] = cb('focus_files'),
			['<M-m>'] = actions.toggle_files,
		},
		file_history_panel = {
			['q'] = cb('close'),
			['gf'] = cb('goto_file_edit'),
			['<M-n>'] = cb('focus_files'),
			['<M-m>'] = cb('toggle_files'),
		},
	},
	view = {
		default = {
			layout = 'diff2_horizontal',
		},
		merge_tool = {
			layout = 'diff4_mixed',
			disable_diagnostics = true,
		},
		file_history = {
			layout = 'diff2_horizontal',
		},
	},
}

-- rhysd/git-messenger.vim
vim.g.git_messenger_floating_win_opts = { border = 'single' }
vim.g.git_messenger_popup_content_margins = false
vim.g.git_messenger_always_into_popup = true
vim.g.git_messenger_no_default_mappings = true

api.nvim_create_autocmd('FileType', {
	pattern = { 'gitmessengerpopup', 'git' },
	callback = function()
		vim.call('fugitive#MapJumps') -- map jumps to hunks/changes like fugitive
		-- remove overlapping maps from fugitive
		vim.keymap.del('n', 'dq', { buffer = 0 })
		vim.keymap.del('n', 'r<Space>', { buffer = 0 })
		vim.keymap.del('n', 'r<CR>', { buffer = 0 })
		vim.keymap.del('n', 'ri', { buffer = 0 })
		vim.keymap.del('n', 'rf', { buffer = 0 })
		vim.keymap.del('n', 'ru', { buffer = 0 })
		vim.keymap.del('n', 'rp', { buffer = 0 })
		vim.keymap.del('n', 'rw', { buffer = 0 })
		vim.keymap.del('n', 'rm', { buffer = 0 })
		vim.keymap.del('n', 'rd', { buffer = 0 })
		vim.keymap.del('n', 'rk', { buffer = 0 })
		vim.keymap.del('n', 'rx', { buffer = 0 })
		vim.keymap.del('n', 'rr', { buffer = 0 })
		vim.keymap.del('n', 'rs', { buffer = 0 })
		vim.keymap.del('n', 're', { buffer = 0 })
		vim.keymap.del('n', 'ra', { buffer = 0 })
		vim.keymap.del('n', 'r?', { buffer = 0 })

		-- add overridden maps
		vim.keymap.set('n', 'o', '<cmd>call b:__gitmessenger_popup.opts.mappings["o"][0]()<CR>', { buffer = 0 })
		vim.keymap.set('n', 'i', '<cmd>call b:__gitmessenger_popup.opts.mappings["O"][0]()<CR>', { buffer = 0 })
	end
})

git_history = function(mode)
	current_line = api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = api.nvim_buf_get_mark(0, "<")
		end_pos = api.nvim_buf_get_mark(0, ">")
	elseif mode == 'n' then
		start_pos = api.nvim_buf_get_mark(0, "[")
		end_pos = api.nvim_buf_get_mark(0, "]")
	end

	start_line = start_pos[1]
	end_line = end_pos[1]

	api.nvim_command('Git log -L' .. start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%'))
end

-- Git submode
-- rhysd/git-messenger.vim
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
		end, { expr = true } },
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
		end, { expr = true } },
		{ '<C-s>', function()
			gitsigns.stage_hunk(nil)
			gitsigns.next_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { silent = true } },
		{ 'r', function()
			gitsigns.reset_hunk(nil)
			gitsigns.next_hunk({ navigation_message = false })
			center_screen()
			return '<Ignore>'
		end, { silent = true } },
		{ 'R', ':Gitsigns reset_buffer<CR>', { silent = true } },
		{ 'u', gitsigns.undo_stage_hunk },
		{ 'S', gitsigns.stage_buffer },
		{ '<C-k>', function()
			actions.conflict_choose("ours")
		end },
		{ '<C-j>', function()
			actions.conflict_choose("theirs")
		end },
		{ '<C-a>', function()
			actions.conflict_choose("all")
		end },
		{ '<Enter>', '<cmd>Git<CR>', { exit = true } },
		-- { 'q', nil, { exit = true, nowait = true } },
		{ '<Esc>',   nil,            { exit = true, nowait = true } },
	}
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
	end
})

-- Flog
vim.g.flog_default_opts = {
	max_count = 512,
	date = 'short',
}

local function get_flog_commit(line)
	return vim.call('flog#floggraph#commit#GetAtLine', line)['hash']
end

local function flog_current_commit()
	return get_flog_commit('.')
end

local function flog_commit_range_visual()
	local start_pos = api.nvim_buf_get_mark(0, "<")
	local end_pos = api.nvim_buf_get_mark(0, ">")

	local start_commit = get_flog_commit(start_pos[1])
	local end_commit = get_flog_commit(end_pos[1])

	return {
		start_commit,
		end_commit
	}
end

function flog_diff_current()
	vim.cmd('DiffviewOpen ' .. flog_current_commit() .. '^')
end

function flog_diff_current_visual()
	local commits = flog_commit_range_visual()
	vim.cmd('DiffviewOpen ' .. commits[2] .. '^..' .. commits[1])
end

function flog_show_current()
	vim.cmd('DiffviewOpen ' .. flog_current_commit() .. '^..' .. flog_current_commit())
end

-- pwntester/octo.nvim
require('octo').setup {
}

-- ofirgall/commit-prefix.nvim
require('commit-prefix').setup {
}
