
vim.cmd([[
command! SolveConflict execute ':Gvdiffsplit!'
command! Conflict execute ':Gvdiffsplit!'
command! Wrap execute ':windo set wrap'
command! NoWrap execute ':windo set nowrap'
]])

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
