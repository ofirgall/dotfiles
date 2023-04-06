if vim.g.started_by_firenvim then
	do return end
end

-- neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

-- simrat39/inlay-hints.nvim
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
	-- No keymaps
	lsp_keymaps = false,
	lsp_codelens = false,
	dap_debug_keymap = false,
	textobjects = false,

	lsp_cfg = {
		capabilities = capabilities,
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
	lsp_on_attach = lsp_on_attach,
	lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
	lsp_inlay_hints = {
		enable = false, -- Using inlay-hints.nvim instead
	},
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
