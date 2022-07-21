require('dapui').setup{
	expand_lines = false,
	layouts = {
		{
			size = 0.25,
			position = 'bottom',
			elements = {
				{ id = 'scopes', size = 0.5 }, -- local vars
				'stacks',
				'watches',
			}
		},
	}
}

-- DAP Config
local dap = require('dap')
-- Sign priority = 11
vim.fn.sign_define('DapBreakpoint', {text='', texthl='DiagnosticError', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='', texthl='DiagnosticWarn', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointRejected', {text='', texthl='DiagnosticWarn', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='', texthl='DiagnosticWarn', linehl='', numhl=''})

dap.configurations.go = {
	{
		name = 'Launch Remote',
		type = 'go',
		request = 'attach',
		mode = 'remote',
		remotePath = '~/go/volumez',
		port = 2345,
		apiVersion = 2,
		cwd = '${workspaceFolder}',
		trace = 'verbose'
	},
}

dap.adapters.go = {
	type = 'server',
	host = 'rv1',
	port = 2345,
}
