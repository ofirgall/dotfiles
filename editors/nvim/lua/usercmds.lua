---@diagnostic disable: assign-type-mismatch
local api = vim.api
local opt = vim.opt
local opt_local = vim.opt_local

local catch = function(what)
	return what[1]
end

local try = function(what)
	status, result = pcall(what[1])
	if not status then
		what[2](result)
	end
	return result
end

close_all_but_current = function()
	for _, bufnr in pairs(api.nvim_list_bufs()) do
		if not buf_is_visible(bufnr) and buf_is_valid(bufnr) then
			try {
				function()
					require('bufdelete').bufwipeout(bufnr, true)
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

api.nvim_create_user_command('CloseAllButCurrent', close_all_but_current, {})

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

api.nvim_create_user_command('ListKeys', require('telescope.builtin').keymaps, {})

-- File utils, chrisgrieser/nvim-genghis
local genghis = require('genghis')
api.nvim_create_user_command('RenameFile', genghis.renameFile, {})
api.nvim_create_user_command('CreateNewFile', genghis.createNewFile, {})
api.nvim_create_user_command('DuplicateFile', genghis.duplicateFile, {})
api.nvim_create_user_command('ChmodX', genghis.chmodx, {})
