local M = {}

table.insert(M, {
	'ray-x/go.nvim',
	dependencies = {
		'ray-x/guihua.lua'
	},
	ft = { 'go', 'gomod' },
	build = ':lua require("go.install").update_all_sync()',
	config = function()
		require('go').setup {
			-- No keymaps
			lsp_keymaps = false,
			lsp_codelens = false,
			dap_debug_keymap = false,
			textobjects = false,
			lsp_on_attach = LSP_ON_ATTACH,
			lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
			lsp_inlay_hints = {
				enable = false, -- Using inlay-hints.nvim instead
			},

			lsp_cfg = {
				capabilities = LSP_CAPS,
				settings = {
					gopls = {
						analyses = {
							ST1003 = false, -- Disable variables format https://staticcheck.io/docs/checks#ST1003
							ST1005 = false, -- Disable error string format https://staticcheck.io/docs/checks#ST1005
							QF1008 = false, -- Disable Hints for Omit embedded fields from selector expression
						},
						usePlaceholders = false,
						hints = { -- For inlay hints
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			},
		}
	end,
})

return M
