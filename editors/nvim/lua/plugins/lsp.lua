-- neovim/nvim-lspconfig
if vim.g.started_by_firenvim then
	do return end
end

local lspconfig = require('lspconfig')

-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_signature_cfg = {
	bind = true,
	use_lspsaga = false,
	doc_lines = 0,
	floating_window = false,
	hint_scheme = 'LspSignatureHintVirtualText',
	hint_prefix = ' ',
}

local lsp_on_attach = function(client, bufnr)
	-- ray-x/lsp_signature.nvim
	require('lsp_signature').on_attach(lsp_signature_cfg)
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

lspconfig.rust_analyzer.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		['rust-analyzer'] = {
			-- enable clippy on save
			checkOnSave = {
				command = 'clippy'
			},
		}
	},
}

-- simrat39/rust-tools.nvim
require('rust-tools').setup {
	server = nil, -- Skip rust-tools lsp setup
	dap = nil, -- Skip rust-tools dap setup
	tools = {
		reload_workspace_from_cargo_toml = false,
		inlay_hints = {
			auto = true,
			highlight = 'InlayHints',
			other_hints_prefix = '   ',
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
}

lspconfig.sumneko_lua.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
		},
	},
}

-- ofirgall/format-on-leave.nvim
require('format-on-leave').setup {
	pattern = { '*.go' }
}

local path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
local words = {}

for word in io.open(path, "r"):lines() do
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
			}
		}
	},
	lsp_on_attach = lsp_on_attach,
	lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
	lsp_inlay_hints = {
		enable = false,
		show_parameter_hints = false,
		other_hints_prefix = '  ',
		highlight = 'InlayHints',
	}
}

require('symbols-outline').setup {
	show_numbers = true,
	show_relative_numbers = true,
	keymaps = {
		goto_location = 'o',
		focus_location = '<Cr>',
	},
	-- TODO: remove when https://github.com/simrat39/symbols-outline.nvim/issues/185 is resolved
	symbols = {
		File = { hl = "@text.uri" },
		Module = { hl = "@namespace" },
		Namespace = { hl = "@namespace" },
		Package = { hl = "@namespace" },
		Class = { hl = "@type" },
		Method = { hl = "@method" },
		Property = { hl = "@method" },
		Field = { hl = "@field" },
		Constructor = { hl = "@constructor" },
		Enum = { hl = "@type" },
		Interface = { hl = "@type" },
		Function = { hl = "@function" },
		Variable = { hl = "@constant" },
		Constant = { hl = "@constant" },
		String = { hl = "@string" },
		Number = { hl = "@number" },
		Boolean = { hl = "@boolean" },
		Array = { hl = "@constant" },
		Object = { hl = "@type" },
		Key = { hl = "@type" },
		Null = { hl = "@type" },
		EnumMember = { hl = "@field" },
		Struct = { hl = "@type" },
		Event = { hl = "@type" },
		Operator = { hl = "@operator" },
		TypeParameter = { hl = "@parameter" },
	},
}
