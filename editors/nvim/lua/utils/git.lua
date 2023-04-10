local M = {}

local api = vim.api

function M.show_history(mode)
	current_line = api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = api.nvim_buf_get_mark(0, '<')
		end_pos = api.nvim_buf_get_mark(0, '>')
	elseif mode == 'n' then
		start_pos = api.nvim_buf_get_mark(0, '[')
		end_pos = api.nvim_buf_get_mark(0, ']')
	end

	start_line = start_pos[1]
	end_line = end_pos[1]

	api.nvim_command('Git log -L' .. start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%'))
end

return M
