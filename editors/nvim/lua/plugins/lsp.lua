if vim.g.started_by_firenvim then
	do return end
end

-- neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

-- simrat39/rust-tools.nvim
require('rust-tools').setup {
	server = {
		on_attach = lsp_on_attach,
		capabilities = capabilities,
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

-- folke/neodev.nvim
require('neodev').setup {
	library = {
		plugins = { 'nvim-treesitter', 'plenary.nvim', 'ofirkai.nvim' },
	},
}

lspconfig.lua_ls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
			hint = {
				enable = true,
			},
		},
	},
}

-- ofirgall/format-on-leave.nvim
require('format-on-leave').setup {
	pattern = { '*.go', '*.rs', '*.lua' },
}


-- RRethy/vim-illuminate
require('illuminate').configure {
	modes_denylist = { 'i' },
}

require('lsp_lines').setup {
}

-- ray-x/go.nvim
require('go').setup {
}

-- simrat39/symbols-outline.nvim
require('symbols-outline').setup {
	show_numbers = true,
	show_relative_numbers = true,
	keymaps = {
		goto_location = 'o',
		focus_location = '<Cr>',
	},
}

-- SmiteshP/nvim-navbuddy
require('nvim-navbuddy').setup {
	lsp = {
		auto_attach = true,
	},
}
