local M = {}

-- TODO: try mason:
-- 'mason.nvim',
-- 'williamboman/mason-lspconfig.nvim',

-- Disable semantic tokens (affects on highlights)
LSP_ON_ATTACH = function(client, buffer)
	client.server_capabilities.semanticTokensProvider = nil
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
	},
	config = function(_, _)
		-- Config diagnostics behavior
		vim.diagnostic.config({
			update_in_insert = false, -- disable updates
			-- Start virtual text and lines disabled
			virtual_lines = false,
			virtual_text = { severity = vim.diagnostic.severity.ERROR },
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

return M
