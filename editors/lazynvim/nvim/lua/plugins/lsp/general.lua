local M = {}

-- TODO: try mason:
-- 'mason.nvim',
-- 'williamboman/mason-lspconfig.nvim',

-- Disable semantic tokens (affects on highlights)
require('utils.lsp').on_attach(function(client, _)
	client.server_capabilities.semanticTokensProvider = nil
end)

table.insert(M, {
	'neovim/nvim-lspconfig',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'hrsh7th/cmp-nvim-lsp',
	},
	config = function(_, _)
		-- Config diagnostics behavior
		vim.diagnostic.config({
			update_in_insert = false, -- disable updates
			-- Start virtual text and lines disabled
			virtual_lines = false,
			virtual_text = { severity = vim.diagnostic.severity.ERROR },
		})

		-- hrsh7th/cmp-nvim-lsp
		local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
		capabilities.textDocument.completion.completionItem.labelDetailsSupport = nil -- Overriding with false doesn't work for some reason

		local function setup_server(server, server_opts)
			local server_opts_merged = vim.tbl_deep_extend('force', {
				capabilities = vim.deepcopy(capabilities),
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
	},
})

return M
