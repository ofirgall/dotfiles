---@diagnostic disable: assign-type-mismatch
local api = vim.api
local opt = vim.opt

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

api.nvim_create_user_command('CloseAllButCurrent', function() require('utils.splits').close_all_but_current() end, {})

api.nvim_create_user_command('CloseBuffersLeft', function()
	api.nvim_command('BufferLineCloseLeft')
end, {})

api.nvim_create_user_command('CloseBuffersRight', function()
	api.nvim_command('BufferLineCloseRight')
end, {})

api.nvim_create_user_command('SetOsClipboard', function()
	opt.clipboard = 'unnamedplus'
end, {})

api.nvim_create_user_command('NoOsClipboard', function()
	opt.clipboard = ''
end, {})


api.nvim_create_user_command('ClearBreakpoints',
	function() require('persistent-breakpoints.api').clear_all_breakpoints() end, {})

api.nvim_create_user_command('ListKeys', function() require('telescope.builtin').keymaps() end, {})

-- TODO: install SSR
api.nvim_create_user_command('SSR', function() require('ssr').open() end, {})
