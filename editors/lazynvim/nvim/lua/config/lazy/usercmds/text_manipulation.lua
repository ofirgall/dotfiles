local api = vim.api

local opt_local = vim.opt_local

api.nvim_create_user_command('PrettifyJson', function()
	api.nvim_exec(':%!python3 -m json.tool --sort-keys --indent 2', false)
	opt_local.filetype = 'jsonc'
end, {})

api.nvim_create_user_command('CompactJson', function()
	api.nvim_exec(':%!python3 -m json.tool --compact', false)
	opt_local.filetype = 'jsonc'
end, {})

api.nvim_create_user_command('ConvertToSpaces', function()
	vim.bo.expandtab = true
	vim.cmd('retab')
end, {})

api.nvim_create_user_command('ConvertToTabs', function()
	vim.bo.expandtab = false
	vim.cmd('retab')
end, {})

api.nvim_create_user_command('BreakLines', function()
	vim.cmd('%!fmt -s -w 300')
end, {})
