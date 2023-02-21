if vim.g.started_by_firenvim then
	do return end
end

-- neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

-- hrsh7th/cmp-nvim-lsp
-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.labelDetailsSupport = nil -- Overriding with false doesn't work for some reason

local lsp_on_attach = function(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil
	-- SmiteshP/nvim-navic
	require('nvim-navic').attach(client, bufnr)
end

if not NO_SUDO then
	lspconfig.pyright.setup {
		on_attach = lsp_on_attach,
		capabilities = capabilities,
	}
else
	lspconfig.pylsp.setup {
		on_attach = lsp_on_attach,
		capabilities = capabilities,
		settings = {
			pylsp = {
				plugins = {
					pycodestyle = {
						enabled = false
					}
				}
			}
		},
	}
end

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
	}
}

-- simrat39/rust-tools.nvim
require('rust-tools').setup {
	server = {
		on_attach = lsp_on_attach,
		capabilities = capabilities,
		settings = {
			['rust-analyzer'] = {
				completion = { callable = { snippets = 'add_parentheses' } }
			}
		}
	},
	tools = {
		reload_workspace_from_cargo_toml = false,
		inlay_hints = {
			auto = false, -- Using inlay-hints.nvim instead
		},
		hover_actions = {
			auto_focus = true,
		},
	}
}

-- Saecki/crates.nvim
require('crates').setup {
}

lspconfig.bashls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
lspconfig.vimls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
lspconfig.cmake.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
lspconfig.cucumber_language_server.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
lspconfig.tsserver.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
lspconfig.marksman.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}

local clang_cmd = { 'clangd', '--background-index', '--fallback-style=none', '--header-insertion=never',
	'--all-scopes-completion', '--cross-file-rename' }

if vim.fn.has('wsl') == 1 then
	table.insert(clang_cmd, '-j=4') -- Limit resources on wsl
end

if NO_SUDO then
	clang_cmd = { 'clangd', '-completion-style=bundled' }
end

lspconfig.clangd.setup {
	init_options = {
		clangdFileStatus = true
	},
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	cmd = clang_cmd,
}

-- folke/neodev.nvim
require('neodev').setup {
	library = {
		plugins = { 'nvim-treesitter', 'plenary.nvim', 'ofirkai.nvim' },
	}
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
	pattern = { '*.go', '*.rs', '*.lua' }
}

local path = vim.fn.stdpath('config') .. '/spell/en.utf-8.add'
local words = {}

for word in io.open(path, 'r'):lines() do
	table.insert(words, word)
end

lspconfig.ltex.setup {
	filetypes = { 'bib', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex' },
	autostart = false,
	settings = {
		ltex = {
			dictionary = {
				['en-US'] = words,
			},
		},
	},
}

-- RRethy/vim-illuminate
require('illuminate').configure {
	modes_denylist = { 'i' },
}

require('lsp_lines').setup {
}

-- Disable update diagnostic while inserting
vim.diagnostic.config({
	update_in_insert = false,

	-- Start virtual text and lines disabled
	virtual_lines = false,
	virtual_text = { severity = vim.diagnostic.severity.ERROR },
})

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
			}
		}
	},
	lsp_on_attach = lsp_on_attach,
	lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
	lsp_inlay_hints = {
		enable = false, -- Using inlay-hints.nvim instead
	}
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
