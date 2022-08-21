
local gs = require('gitsigns')
gs.setup {
	sign_priority = 1,
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or { silent=true }
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end
		-- Navigation
		map('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(function() gs.next_hunk() end)
			return '<Ignore>'
		end, {expr=true})

		map('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(function() gs.prev_hunk() end)
			return '<Ignore>'
		end, {expr=true})
		-- Actions
		map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
		map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
		map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
		map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
		map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
		map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
		map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
		map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns toggle_deleted<CR>')
		-- Text object
		map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end
}

local cb = require'diffview.config'.diffview_callback
require'diffview'.setup{
	file_history_panel = {
		log_options = {
			single_file = {
				follow = true,
			}
		},
	},
	key_bindings = {
		view = {
			["q"] = '<cmd>:DiffviewClose<cr>',
			["<Escape>"] = '<cmd>:DiffviewClose<cr>',
			["gf"] = cb("goto_file_edit"),
			["<M-n>"] = cb("focus_files"),
			["<M-m>"] = cb("toggle_files"),
		},
		file_panel = {
			["s"] = cb("toggle_stage_entry"),
			["q"] = cb('close'),
			["<Escape>"] = cb('close'),
			["gf"] = cb("goto_file_edit"),
			["<M-n>"] = cb("focus_files"),

		},
		file_history_panel = {
			["q"] = cb('close'),
			["<Escape>"] = cb('close'),
			["gf"] = cb("goto_file_edit"),
			["<M-n>"] = cb("focus_files"),
			["<M-m>"] = cb("toggle_files"),
		},
	}
}

-- Flog
vim.g.flog_default_arguments = {
	max_count = 512,
	date = 'short',
}

-- git-messenger.vim
vim.g.git_messenger_floating_win_opts = { border = 'single' }
vim.g.git_messenger_popup_content_margins = false
vim.g.git_messenger_always_into_popup = true
vim.g.git_messenger_no_default_mappings = true

vim.api.nvim_create_autocmd('FileType', {
	pattern = {'gitmessengerpopup', 'git'},
	callback = function()
		vim.call('fugitive#MapJumps') -- map jumps to hunks/changes like fugitive
		-- remove overlapping maps from fugitive
		vim.keymap.del('n', 'dq', { buffer = 0 })
		vim.keymap.del('n', 'r<Space>', {buffer = 0})
		vim.keymap.del('n', 'r<CR>', {buffer = 0})
		vim.keymap.del('n', 'ri', {buffer = 0})
		vim.keymap.del('n', 'rf', {buffer = 0})
		vim.keymap.del('n', 'ru', {buffer = 0})
		vim.keymap.del('n', 'rp', {buffer = 0})
		vim.keymap.del('n', 'rw', {buffer = 0})
		vim.keymap.del('n', 'rm', {buffer = 0})
		vim.keymap.del('n', 'rd', {buffer = 0})
		vim.keymap.del('n', 'rk', {buffer = 0})
		vim.keymap.del('n', 'rx', {buffer = 0})
		vim.keymap.del('n', 'rr', {buffer = 0})
		vim.keymap.del('n', 'rs', {buffer = 0})
		vim.keymap.del('n', 're', {buffer = 0})
		vim.keymap.del('n', 'ra', {buffer = 0})
		vim.keymap.del('n', 'r?', {buffer = 0})

		-- add overridden maps
		vim.keymap.set('n', 'o', '<cmd>call b:__gitmessenger_popup.opts.mappings["o"][0]()<CR>', { buffer = 0 })
		vim.keymap.set('n', 'i', '<cmd>call b:__gitmessenger_popup.opts.mappings["O"][0]()<CR>', { buffer = 0 })
	end
})

git_history = function(mode)
	current_line = vim.api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = vim.api.nvim_buf_get_mark(0, "<")
		end_pos = vim.api.nvim_buf_get_mark(0, ">")
	elseif mode == 'n' then
		start_pos = vim.api.nvim_buf_get_mark(0, "[")
		end_pos = vim.api.nvim_buf_get_mark(0, "]")
	end

	start_line = start_pos[1]
	end_line = end_pos[1]

	vim.api.nvim_command('Git log -L' .. start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%'))
end

