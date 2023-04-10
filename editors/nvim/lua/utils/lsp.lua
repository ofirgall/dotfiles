local M = {}

local api = vim.api

function M.goto_next_diag()
	local next = vim.diagnostic.get_next()
	if next == nil then
		return
	end
	api.nvim_win_set_cursor(0, { next.lnum + 1, next.col })
	require('utils.misc').center_screen()
end

function M.goto_prev_diag()
	local prev = vim.diagnostic.get_prev(opts)
	if not prev then
		return
	end
	api.nvim_win_set_cursor(0, { prev.lnum + 1, prev.col })
	require('utils.misc').center_screen()
end

return M