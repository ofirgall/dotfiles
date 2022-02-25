
local api = vim.api

vsplit_if_not_exist = function()
	local tabpage = api.nvim_get_current_tabpage()
	local win_ids = api.nvim_tabpage_list_wins(tabpage)
	local current_win = api.nvim_get_current_win()

	local current_win_row = api.nvim_win_get_position(current_win)[1]

	for _, win_id in ipairs(win_ids) do
		if win_id ~= current_win then
			local file_type = api.nvim_buf_get_option(api.nvim_win_get_buf(win_id), 'filetype')
			if file_type ~= 'NvimTree' then
				local row = api.nvim_win_get_position(win_id)[1]
				if current_win_row == row then
					api.nvim_win_set_buf(win_id, api.nvim_win_get_buf(0))
					api.nvim_set_current_win(win_id)
					return
				end
			end
		end
	end

	-- Didnt return create new split
	vim.fn.execute('vsplit')
end

xsplit_if_not_exist = function()
	local tabpage = api.nvim_get_current_tabpage()
	local win_ids = api.nvim_tabpage_list_wins(tabpage)
	local current_win = api.nvim_get_current_win()

	local current_win_col = api.nvim_win_get_position(current_win)[2]

	for _, win_id in ipairs(win_ids) do
		if win_id ~= current_win then
			local file_type = api.nvim_buf_get_option(api.nvim_win_get_buf(win_id), 'filetype')
			if file_type ~= 'NvimTree' then
				local col = api.nvim_win_get_position(win_id)[2]
				if current_win_col == col then
					api.nvim_win_set_buf(win_id, api.nvim_win_get_buf(0))
					api.nvim_set_current_win(win_id)
					return
				end
			end
		end
	end

	-- Didnt return create new split
	vim.fn.execute('split')
end
