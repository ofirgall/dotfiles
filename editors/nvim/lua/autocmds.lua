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
	end,
})

-- Auto spell files
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'gitcommit', 'markdown' },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Small quickfix
local QUICKFIX_HEIGHT = 6
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'qf' },
	callback = function()
		api.nvim_win_set_height(0, QUICKFIX_HEIGHT)
	end,
})

-- Auto set .tmux filetype
api.nvim_create_autocmd('BufEnter', {
	group = config_autocmds,
	pattern = '*.tmux',
	callback = function(events)
		api.nvim_buf_set_option(events.buf, 'filetype', 'tmux')
	end,
})

-- Vertical help/man
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'help', 'man' },
	callback = function()
		vim.cmd('wincmd L')
	end,
})

-- Switch layout when half screen
local ui = require('ui')
local function set_half_layout()
	ui.setup_lualine(true)
end

local function set_full_layout()
	ui.setup_lualine(false)
end

local FULL_SCREEN_WIDTH = 212 -- echo $COLUMNS, TODO: figure out how to check is half without it
local function is_half()
	return api.nvim_get_option_value('columns', {}) <= FULL_SCREEN_WIDTH / 2
end

local function set_layout()
	if is_half() then
		set_half_layout()
	else
		set_full_layout()
	end
end

local LAST_STATE = false
api.nvim_create_autocmd('VimEnter', {
	group = config_autocmds,
	callback = function()
		LAST_STATE = is_half()
		set_layout()
	end,
})
api.nvim_create_autocmd('VimResized', {
	group = config_autocmds,
	callback = function()
		local new_state = is_half()
		if LAST_STATE == new_state then
			return -- No need to do anything
		end
		set_layout()
		LAST_STATE = new_state
	end,
})
