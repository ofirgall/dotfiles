---@diagnostic disable: assign-type-mismatch
local api = vim.api
local opt = vim.opt

config_autocmds = api.nvim_create_augroup('config', { clear = true })

-- Enable and disable mouse when gaining/losing focus to avoid the first click jump
api.nvim_create_autocmd('FocusGained', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		opt.mouse = 'a'
	end
})
api.nvim_create_autocmd('FocusLost', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		opt.mouse = ''
	end
})

-- Highlight on yank
api.nvim_create_autocmd('TextYankPost', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		vim.highlight.on_yank({ timeout = 350, higroup = 'Visual' })
	end
})

-- Auto spell files
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'gitcommit', 'markdown' },
	callback = function()
		vim.opt_local.spell = true
	end
})

-- Small quickfix
local QUICKFIX_HEIGHT = 6
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'qf' },
	callback = function()
		api.nvim_win_set_height(0, QUICKFIX_HEIGHT)
	end
})
