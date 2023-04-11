local M = {}

table.insert(M, {
	'mfussenegger/nvim-dap',
	config = function()
		local dap = require('dap')
		dap.defaults.fallback.stepping_granularity = 'line'
		--- Signs ---
		-- Sign priority = 11
		vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })
		vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
		vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
		vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
		vim.fn.sign_define('DapStopped',
			{ text = '', texthl = 'DiagnosticInfo', linehl = 'CursorLine', numhl = 'CursorLine' })

		--- Setup Adapaters ---

		-- C/C++/Rust
		local last_file = './a.out'
		dap.configurations.cpp = {
			{
				name = 'Launch file',
				type = 'codelldb',
				request = 'launch',
				program = function()
					---@diagnostic disable-next-line: redundant-parameter, param-type-mismatch
					last_file = vim.fn.input('Path to executable: ', last_file, 'file')
					return last_file
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
			},
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
			host = 'rhel8-5.local',
			port = 2345,
		}
	end,
	lazy = true, -- Loading with dap-ui
	keys = {
		{ '<F5>', function() require 'dap'.continue() end, desc = 'Debug: continue' },
		{ '<F6>', function() require 'dap'.terminate() end, desc = 'Debug: terminate' },
		{
			'<F10>',
			function()
				require('dap').step_over()
				require('utils.misc').center_screen()
			end,
			desc = 'Debug: step over',
		},
		{
			'<F11>',
			function()
				require('dap').step_into()
				require('utils.misc').center_screen()
			end,
			desc = 'Debug: step into',
		},
		{
			'<F12>',
			function()
				require('dap').step_out()
				require('utils.misc').center_screen()
			end,
			desc = 'Debug: set out',
		},
		{
			'<leader>rp',
			function() require('dap').repl.open() end,
			desc = 'Debug: open repl',
		},
		{
			'<leader>rc',
			function() require('dap').run_to_cursor() end,
			desc = 'Debug: Run to cursor',
		},
		{
			'<leader>k',
			function() require('dapui').eval() end,
			desc = 'Debug: evaluate',
		},
	},
})


table.insert(M, {
	'rcarriga/nvim-dap-ui',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'ofirgall/format-on-leave.nvim'
	},
	config = function()
		local dapui = require('dapui')
		dapui.setup {
			expand_lines = false,
			layouts = {
				{
					size = 0.15,
					position = 'top',
					elements = {
						'scopes' -- local vars
					},
				},
				{
					size = 0.20,
					position = 'right',
					elements = {
						'watches',
						'breakpoints',
						'stacks',
					},
				},
			},
		}

		local dap_closed = function()
			dapui.close({})
			vim.api.nvim_command('tabclose $') -- $(last) is the debug page

			require('utils.map').map('n', '<RightMouse>',
				'<LeftMouse><cmd>sleep 100m<cr><cmd>lua vim.lsp.buf.hover()<cr>', 'Trigger hover')

			require('format-on-leave').enable()
		end

		local dap = require('dap')
		-- Hooks to dap, opens/cloes dap-ui binds rightlick to evaluate
		dap.listeners.after.event_initialized['dapui_config'] = function()
			vim.api.nvim_command('$tabnew') -- $(last) is the debug page
			dapui.open({})

			require('utils.map').map('n', '<RightMouse>', '<LeftMouse><cmd>lua require"dapui".eval()<cr>') -- Trigger hover

			require('format-on-leave').disable()
		end
		dap.listeners.before.event_terminated['dapui_config'] = function()
			dap_closed()
		end
		dap.listeners.before.event_exited['dapui_config'] = function()
			dap_closed()
		end
	end,
})

table.insert(M, {
	'Weissle/persistent-breakpoints.nvim',
	dependencies = {
		'mfussenegger/nvim-dap',
		'rmagatti/auto-session',
	},
	lazy = false, -- make sure to load this before any files loaded
	config = function()
		require('persistent-breakpoints').setup {
			-- load_breakpoints_event = { 'BufReadPost' },
		}
		vim.api.nvim_create_autocmd('BufReadPost', {
			pattern = '*',
			callback = require('persistent-breakpoints.api').load_breakpoints,
		})
	end,
	keys = {
		{
			'<F9>',
			function() require('persistent-breakpoints.api').toggle_breakpoint() end,
			desc = 'Debug: Toggle breakpoint',
		},
		{
			'<leader><F9>',
			function() require('persistent-breakpoints.api').set_conditional_breakpoint() end,
			desc = 'Debug: toggle conditional breakpoint',
		},
	},
})

table.insert(M, {
	-- Cycle breakpoints with ]d/[d
	'ofirgall/goto-breakpoints.nvim',
	keys = {
		{ ']d', function() require('goto-breakpoints').next() end, desc = 'Goto next breakpoint' },
		{ '[d', function() require('goto-breakpoints').prev() end, desc = 'Goto prev breakpoint' },
		{ ']S', function() require('goto-breakpoints').stopped() end, desc = 'Goto DAP stopped location' },
	},
})

return M
