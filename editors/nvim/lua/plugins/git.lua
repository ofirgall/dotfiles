
vim.cmd([[
command! SolveConflict execute ':Gvdiffsplit!'
command! Conflict execute ':Gvdiffsplit!'
command! Wrap execute ':windo set wrap'
command! NoWrap execute ':windo set nowrap'
]])

-- TODO: when updating to nvim7 update the usage, move to keymaps somehow
require('gitsigns').setup {
	sign_priority = 10000,
	on_attach = function(bufnr)
		local function map(mode, lhs, rhs, opts)
			opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
			vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
		end
		-- Navigation
		map('n', ']c', "&diff ? ']czz' : '<cmd>Gitsigns next_hunk<CR>zz'", {expr=true})
		map('n', '[c', "&diff ? '[czz' : '<cmd>Gitsigns prev_hunk<CR>zz'", {expr=true})
		-- Actions
		map('n', '<leader>hs', "&diff ? '<cmd>Gitsigns stage_hunk<CR>]c' : '<cmd>Gitsigns stage_hunk<CR>'", {expr=true})
		map('v', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>')
		map('n', '<leader>hr', "&diff ? '<cmd>Gitsigns reset_hunk<CR>]c' : '<cmd>Gitsigns reset_hunk<CR>'", {expr=true})
		map('v', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>')
		map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
		map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
		map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
		map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
		map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
		map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
		map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		map('n', '<leader>gd', '<cmd>Gitsigns toggle_deleted<CR>')
		-- Text object
		map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
		map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
	end
}

local cb = require'diffview.config'.diffview_callback
require'diffview'.setup{
	file_history_panel = {
		-- height = 5,
		log_options = {
			follow = true,
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
			["<M-m>"] = cb("toggle_files"),
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
