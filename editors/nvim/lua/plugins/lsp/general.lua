local M = {}

-- TODO: try mason:
-- 'mason.nvim',
-- 'williamboman/mason-lspconfig.nvim',

LSP_ON_ATTACH = function(client, buffer)
	-- Disable semantic tokens (affects on highlights)
	client.server_capabilities.semanticTokensProvider = nil

	-- Attach navic
	if client.server_capabilities.documentSymbolProvider then
		require('nvim-navic').attach(client, buffer)
	end
end

-- hrsh7th/cmp-nvim-lsp
LSP_CAPS = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
LSP_CAPS.textDocument.completion.completionItem.labelDetailsSupport = nil -- Overriding with false doesn't work for some reason


-- Setup actual servers + generic lsp stuff
table.insert(M, {
	'neovim/nvim-lspconfig',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'hrsh7th/cmp-nvim-lsp',
		'folke/neodev.nvim', -- Must be loaded before setting up lua_ls
		{
			'mhanberg/output-panel.nvim',
			config = function()
				require('output_panel').setup()
				vim.api.nvim_create_user_command('LspOutput', ':OutputPanel', {})
			end,
		},
	},
	config = function(_, _)
		-- Config diagnostics behavior
		vim.diagnostic.config({
			update_in_insert = false, -- disable updates
			-- Start virtual text and lines disabled
			virtual_lines = false,
			virtual_text = { severity = vim.diagnostic.severity.ERROR },
			signs = {
				priority = 8,
			},
		})

		local function setup_server(server, server_opts)
			local server_opts_merged = vim.tbl_deep_extend('force', {
				capabilities = LSP_CAPS,
				on_attach = LSP_ON_ATTACH,
			}, server_opts)
			require('lspconfig')[server].setup(server_opts_merged)
		end

		for server, server_opts in pairs(LSP_SERVERS) do
			setup_server(server, server_opts)
		end
	end,
	keys = {
		{ 'gD', vim.lsp.buf.declaration, desc = 'Go to Declaration' },
		{ '<leader>F', function() vim.lsp.buf.format({ async = true }) end, desc = 'Format' },
		{ 'K', vim.lsp.buf.hover, desc = 'Trigger hover' },
		{ '<RightMouse>', '<LeftMouse><cmd>sleep 100m<cr><cmd>lua vim.lsp.buf.hover()<cr>', desc = 'Trigger hover' },
	},
})

-- TODO: if I want code action to be always active I need to add event = 'LspAttach'
table.insert(M, {
	'glepnir/lspsaga.nvim',
	dependencies = {
		'kyazdani42/nvim-web-devicons',
		'nvim-treesitter/nvim-treesitter',
	},
	config = function()
		local scheme = require('ofirkai.design').scheme

		require('lspsaga').setup({
			code_action = {
				keys = {
					quit = '<Escape>',
					exec = '<CR>',
				},
			},
			lightbulb = {
				sign_priority = 10,
				sign = true,
				virtual_text = false,
				enable_in_insert = false,
			},
			rename = {
				in_select = false,
				whole_project = false,
			},
			symbol_in_winbar = {
				enable = false,
			},
			ui = {
				code_action = '',
				colors = {
					normal_bg = scheme.ui_bg,
					title_bg = scheme.mid_orange,
				},
			},
		})
	end,
	keys = {
		{ '<F2>', '<cmd>Lspsaga rename<cr>', desc = 'Rename symbos with F2' },
		{ '<F4>', '<cmd>Lspsaga code_action<cr>', desc = 'Code action with F4' },
		{ '<leader>L', '<cmd>Lspsaga show_line_diagnostics<CR>', desc = 'show Problem' },
	},
})

table.insert(M, {
	'ofirgall/inlay-hints.nvim', -- fork
	keys = {
		{ '<leader>t', function() require('inlay-hints').toggle() end, desc = 'Toggle inlay-hints' },
	},
	config = function()
		local function trim_hint(hint)
			return string.gsub(hint, ':', '')
		end

		require('inlay-hints').setup {
			renderer = 'inlay-hints/render/eol',

			hints = {
				parameter = {
					show = true,
					highlight = 'InlayHints',
				},
				type = {
					show = true,
					highlight = 'InlayHints',
				},
			},

			eol = {
				parameter = {
					separator = ', ',
					format = function(hint)
						return string.format('  (%s)', trim_hint(hint))
					end,
				},
				type = {
					separator = ', ',
					format = function(hint)
						return string.format('  %s', trim_hint(hint))
					end,
				},
			},
		}
	end,
})

table.insert(M, {
	'ofirgall/format-on-leave.nvim',
	ft = { 'go', 'rust', 'lua' },
	config = function()
		require('format-on-leave').setup {
			pattern = { '*.go', '*.rs', '*.lua' },
		}
	end,
})

table.insert(M, {
	'RRethy/vim-illuminate',
	event = 'LspAttach',
	config = function()
		require('illuminate').configure {
			modes_denylist = { 'i' },
		}
	end,
	keys = {
		{
			'<C-n>',
			function() require 'illuminate'.goto_next_reference({ wrap = true }) end,
			desc = 'jump to Next occurrence of var on cursor',
		},
		{
			'<C-p>',
			function() require 'illuminate'.goto_prev_reference({ reverse = true, wrap = true }) end,
			desc = 'jump to Previous occurrence of var on cursor',
		},

	},
})

-- Disable virtual text and enables lsp lines and vise versa
toggle_lsp_diagnostics = function()
	local new_lines_value = not vim.diagnostic.config().virtual_lines
	local virtual_text = nil

	if new_lines_value == false then
		virtual_text = { severity = vim.diagnostic.severity.ERROR }
	else
		virtual_text = false
	end

	vim.diagnostic.config({
		virtual_lines = new_lines_value,
		virtual_text = virtual_text,
	})
end

table.insert(M, {
	'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
	config = function()
		require('lsp_lines').setup {
		}
	end,
	keys = {
		{ '<leader>l', toggle_lsp_diagnostics, desc = 'Toggle lsp diagnostics' },
	},
})

table.insert(M, {
	'SmiteshP/nvim-navbuddy',
	cmd = 'Navbuddy',
	dependencies = {
		'SmiteshP/nvim-navic',
		'MunifTanjim/nui.nvim'
	},
	config = function()
		require('nvim-navbuddy').setup {
			window = {
				size = '80%',
				left = {
					size = '20%',
				},
				mid = {
					size = '20%',
				},
			},
			lsp = {
				auto_attach = true,
			},
		}

		require('utils.lsp').late_attach(function(client, bufnr)
			require('nvim-navbuddy').attach(client, bufnr)
		end)

		-- For some reason the usercmd doesn't get called after setup perhaps its mapped to the buffer
		vim.api.nvim_create_user_command('Navbuddy', function()
			require('nvim-navbuddy').open()
		end, {})
	end,
	keys = {
		{ '<C-g>s', function()
			require('nvim-navbuddy').open()
		end, desc = 'Open Navbuddy' },
	},
})

return M
