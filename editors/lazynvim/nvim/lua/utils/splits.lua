local M = {}

local api = vim.api

function M.close_all_but_current()
	local buf_utils = require('utils.buf')
	for _, bufnr in pairs(api.nvim_list_bufs()) do
		if not buf_utils.is_visible(bufnr) and buf_utils.is_valid(bufnr) then
			try {
				function()
					require('bufdelete').bufwipeout(bufnr, true)
				end,
				catch {
					function()
						-- print('Failed to delete buffer: ' .. bufnr)
					end,
				},
			}
		end
	end
end

function M.close()
	local bufnr = api.nvim_get_current_buf()
	if #api.nvim_list_wins() == 1 then -- Sometimes its reports 2 instead of 1
		api.nvim_feedkeys(':q\n', 'n', false)
		return
	end
	api.nvim_win_close(0, true)
	if not require('utils.buf').is_visible(bufnr) then
		if api.nvim_buf_is_loaded(bufnr) then
			require('bufdelete').bufdelete(bufnr, true)
		end
	end
end

function M.smart_split(direction)
	local ft = api.nvim_buf_get_option(0, 'filetype')
	if ft == 'toggleterm' then
		open_new_terminal(direction)
	else
		if direction == 'vertical' then
			api.nvim_input('<cmd>vsplit<cr>')
		else
			api.nvim_input('<cmd>split<cr>')
		end
	end
end

function M.split_if_not_exist(is_vsplit)
	if is_vsplit then
		pos_index = 1
		split_command = 'vsplit'
	else
		pos_index = 2
		split_command = 'split'
	end

	local win_ids = api.nvim_tabpage_list_wins(api.nvim_get_current_tabpage())
	local current_win = api.nvim_get_current_win()

	local current_win_pos = api.nvim_win_get_position(current_win)[pos_index]

	for _, win_id in ipairs(win_ids) do
		if win_id ~= current_win then
			local floating = api.nvim_win_get_config(win_id).relative ~= ''
			local file_type = api.nvim_buf_get_option(api.nvim_win_get_buf(win_id), 'filetype')
			if file_type ~= 'NvimTree' and not floating then
				local row = api.nvim_win_get_position(win_id)[pos_index]
				if current_win_pos == row then
					api.nvim_win_set_buf(win_id, api.nvim_win_get_buf(0))
					api.nvim_win_set_cursor(win_id, api.nvim_win_get_cursor(current_win))
					api.nvim_set_current_win(win_id)
					return
				end
			end
		end
	end

	-- Didnt return create new split
	vim.fn.execute(split_command)
end

return M
