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

-- TODO: export to plugin
-- Auto ticket number in git commit
api.nvim_create_autocmd('BufWinEnter', {
	group = config_autocmds,
	callback = function(events)
		local ft = api.nvim_buf_get_option(events.buf, 'filetype')
		if ft ~= 'gitcommit' then
			return
		end
		local first_line = api.nvim_buf_get_lines(events.buf, 0, 1, true)[1]
		if first_line == '' then
			local on_branch_line_index = vim.fn.search('# On branch', 'n')
			local on_branch = api.nvim_buf_get_lines(events.buf, on_branch_line_index - 1, on_branch_line_index, true)[1]
			local branch = string.gsub(on_branch, '# On branch', '')
			local ticket_num = branch:match('%w+-%d+')

			if ticket_num then
				api.nvim_buf_set_lines(events.buf, 0, 1, true, { ticket_num .. ' ' })
			end
			-- Insert at EOL
			api.nvim_feedkeys('A', 'n', false)
		end
	end
})

-- Simple color scheme for `tmp log`
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'log' },
	once = true,
	callback = function()
		if #api.nvim_list_wins() == 1 then
			vim.cmd('colorscheme pablo')
		end
	end
})

-- Vertical help/man
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'help', 'man' },
	callback = function()
		vim.cmd('wincmd L')
	end
})
