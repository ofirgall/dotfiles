local M = {}


table.insert(M, {
	'simrat39/rust-tools.nvim',
	config = function()
		require('rust-tools').setup {
			server = {
				on_attach = LSP_ON_ATTACH,
				capabilities = LSP_CAPS,
				settings = {
					['rust-analyzer'] = {
						completion = { callable = { snippets = 'add_parentheses' } },
					},
				},
			},
			tools = {
				reload_workspace_from_cargo_toml = false,
				inlay_hints = {
					auto = false, -- Using inlay-hints.nvim instead
				},
				hover_actions = {
					auto_focus = true,
				},
			},
		}
	end,
})

return M
