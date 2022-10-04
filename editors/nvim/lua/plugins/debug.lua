if vim.g.started_by_firenvim then
	do return end
end

-- mfussenegger/nvim-dap
local dap = require('dap')

--- Signs ---
-- Sign priority = 11
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticInfo', linehl = 'CursorLine', numhl = 'CursorLine' })

-- C/C++/Rust
dap.configurations.cpp = {
	{
		name = 'Launch file',
		type = 'codelldb',
		request = 'launch',
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/a.out', 'file')
		end,
		cwd = vim.fn.getcwd(),
		stopOnEntry = false,
	},
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.adapters.codelldb = {
	type = 'server',
	port = '${port}',
	executable = {
		command = 'codelldb',
		args = { '--port', '${port}' },
	}
}

-- Golang
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

-- rcarriga/nvim-dap-ui
local dapui = require('dapui')
dapui.setup {
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
			size = 0.20,
			position = 'left',
			elements = {
				'breakpoints',
				'watches',
				'stacks',
			}
		},
	}
}

local function map(mode, l, r, opts)
	opts = opts or { silent = true }
	vim.keymap.set(mode, l, r, opts)
end

local dap_closed = function()
	dapui.close({})
	vim.api.nvim_command('tabclose $') -- $(last) is the debug page
	map('n', '<RightMouse>', '<LeftMouse><cmd>Lspsaga hover_doc<cr>') -- Trigger hover
end

-- Hooks to dap, opens/cloes dap-ui binds rightlick to evaluate
dap.listeners.after.event_initialized['dapui_config'] = function()
	vim.api.nvim_command('$tabnew') -- $(last) is the debug page
	dapui.open({})
	map('n', '<RightMouse>', '<LeftMouse><cmd>lua require"dapui".eval()<cr>') -- Trigger hover
end
dap.listeners.before.event_terminated['dapui_config'] = function()
	dap_closed()
end
dap.listeners.before.event_exited['dapui_config'] = function()
	dap_closed()
end

-- Weissle/persistent-breakpoints.nvim
require('persistent-breakpoints').setup {}
vim.api.nvim_create_autocmd('BufReadPost', {
	pattern = '*',
	callback = require('persistent-breakpoints.api').load_breakpoints
})
