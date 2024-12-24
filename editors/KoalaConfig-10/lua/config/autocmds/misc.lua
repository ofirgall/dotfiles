local api = vim.api

local config_autocmds = api.nvim_create_augroup('config_not_lazy', { clear = true })

local uv = vim.loop

api.nvim_create_autocmd({'VimEnter', 'VimLeave'}, {
	group = config_autocmds,
	callback = function()
		if vim.env.TMUX_PLUGIN_MANAGER_PATH then
			uv.spawn(vim.env.TMUX_PLUGIN_MANAGER_PATH .. '/tmux-window-name/scripts/rename_session_windows.py', {})
		end
	end,
})
