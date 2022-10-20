---@diagnostic disable: assign-type-mismatch
local api = vim.api
local opt = vim.opt
local opt_local = vim.opt_local

api.nvim_create_user_command('CloseAllButCurrent', function()
	for _, bufnr in pairs(api.nvim_list_bufs()) do
		if not buf_is_visible(bufnr) then
			if api.nvim_buf_is_valid(bufnr) then
				try {
					function()
						require('bufdelete').bufdelete(bufnr, true)
					end,
					catch {
						function()
							-- print('Failed to delete buffer: ' .. bufnr)
						end
					}
				}
			end
		end
	end
end, {})

api.nvim_create_user_command('CloseBuffersLeft', function()
	api.nvim_command('BufferLineCloseLeft')
end, {})
api.nvim_create_user_command('CloseBuffersRight', function()
	api.nvim_command('BufferLineCloseRight')
end, {})

api.nvim_create_user_command('PrettifyJson', function()
	api.nvim_exec(':%!python3 -m json.tool --sort-keys --indent 2', false)
	opt_local.filetype = 'jsonc'
end, {})

api.nvim_create_user_command('CompactJson', function()
	api.nvim_exec(':%!python3 -m json.tool --compact', false)
	opt_local.filetype = 'jsonc'
end, {})

api.nvim_create_user_command('SetOsClipboard', function()
	opt.clipboard = 'unnamedplus'
end, {})

api.nvim_create_user_command('NoOsClipboard', function()
	opt.clipboard = ''
end, {})


api.nvim_create_user_command('ClearBreakpoints', require('persistent-breakpoints.api').clear_all_breakpoints, {})
