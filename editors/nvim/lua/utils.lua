
local api = vim.api

local file_exists = function(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

NO_SUDO = file_exists(os.getenv("HOME") .. "/.no_sudo_indicator")
IS_REMOTE = file_exists(os.getenv("HOME") .. "/.remote_indicator")

split_if_not_exist = function(is_vsplit)
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
			local file_type = api.nvim_buf_get_option(api.nvim_win_get_buf(win_id), 'filetype')
			if file_type ~= 'NvimTree' then
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

create_title = function()
	local title = vim.fn.input("Title: ")
	local len = vim.fn.input("Title Length: ", 30)
	local filler_char = vim.fn.input("Filler: ", "-")
	local amount_of_lines = vim.fn.input("Amount of lines: ", "1")

	local filler_amount = (len - string.len(title) - 2) / 2
	local filler = ""
	for _ = 1, filler_amount, 1 do
		filler = filler .. filler_char
	end

	local output_title = filler .. ' ' .. title .. ' ' .. filler
	local wrapped_line = ""
	for _ = 1, len, 1 do
		wrapped_line = wrapped_line .. filler_char
	end

	local lines = {}
	for _ = 1, amount_of_lines / 2, 1 do
		table.insert(lines, wrapped_line)
	end
	table.insert(lines, output_title)
	for _ = 1, amount_of_lines / 2, 1 do
		table.insert(lines, wrapped_line)
	end

	local pos = api.nvim_win_get_cursor(0)[1] - 1
	api.nvim_buf_set_lines(0, pos, pos, false, lines)
end
api.nvim_create_user_command('Title', create_title, {})
