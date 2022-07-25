local dapui = require('dapui')
dapui.setup{
	expand_lines = false,
	layouts = {
		{
			size = 0.25,
			position = 'bottom',
			elements = {
				'scopes' -- local vars
			}
		},
		{
			size = 0.25,
			position = 'left',
			elements = {
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

-- Auto open and close dapui
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end
