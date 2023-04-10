local M = {}

local api = vim.api

function M.is_visible(bufnr)
	return api.nvim_buf_is_loaded(bufnr) and vim.fn.bufwinnr(bufnr) > 0
end

function M.is_valid(bufnr)
	if not bufnr or bufnr < 1 then
		return false
	end
	local exists = vim.api.nvim_buf_is_valid(bufnr)
	return vim.bo[bufnr].buflisted and exists
end

return M
