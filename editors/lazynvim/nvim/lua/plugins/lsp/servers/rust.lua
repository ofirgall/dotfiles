local M = {}


table.insert(M, {
	'simrat39/rust-tools.nvim',
	ft = 'rust',
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

		local map_buffer = require('utils.misc').map_buffer
		vim.api.nvim_create_autocmd('FileType', {
			pattern = 'rust',
			callback = function(events)
				local bufid = events.buf
				map_buffer(bufid, 'n', 'J', require('rust-tools').join_lines.join_lines, 'Rust: join line')
				map_buffer(bufid, 'n', '<leader>rr', require('rust-tools').runnables.runnables, 'Rust: run')
				map_buffer(bufid, 'n', '<leader>rt', require('rust-tools').hover_actions.hover_actions, 'Rust: run test') -- run test
			end,
		})
	end,
})

return M
