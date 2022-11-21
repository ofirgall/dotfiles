---@diagnostic disable: assign-type-mismatch
local api = vim.api
local opt = vim.opt

config_autocmds = api.nvim_create_augroup('config', { clear = true })

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

-- Auto set .tmux filetype
api.nvim_create_autocmd('BufEnter', {
	group = config_autocmds,
	pattern = '*.tmux',
	callback = function(events)
		api.nvim_buf_set_option(events.buf, 'filetype', 'tmux')
	end
})
