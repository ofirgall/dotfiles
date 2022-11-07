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
	-- ray-x/navigator.lua
	require('navigator.lspclient.mapping').setup({ bufnr = bufnr, client = client })
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
		inlay_hints = {
			auto = false,
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
	pattern = { '*.rs', '*.go' }
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

-- Disable update diagnostic while inserting
vim.diagnostic.config({
	update_in_insert = false,
	virtual_lines = false, -- Start lsp_lines disabled as default
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
				}
			}
		}
	},
	lsp_on_attach = lsp_on_attach,
	lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
	lsp_inlay_hints = {
		enable = true,
		show_parameter_hints = false,
		other_hints_prefix = '',
		highlight = 'InlayHints', -- TODO: try something different
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

require 'navigator'.setup {
	-- No extra setups
	default_mapping = false,
	signature_help_cfg = nil,
	lsp = {
		code_action = { enable = false, sign = false, },
		code_lens_action = { enable = false, sign = false },
		format_on_save = false,
		document_highlight = false, -- TODO
		hover = false,

		disable_lsp = 'all',

		diagnostic = {
			underline = true,
			virtual_text = false,
		},
		diagnostic_virtual_text = false,
		diagnostic_update_in_insert = false,
		disply_diagnostic_qf = false,
		diagnostic_scrollbar_sign = false,
	},
	icons = {
		diagnostic_head = '🐛',
		diagnostic_err = '',
		diagnostic_warn = '',
		diagnostic_info = '',
		diagnostic_hint = '',

		-- Warnings
		diagnostic_head_severity_1 = '',
		diagnostic_head_severity_2 = '',
		diagnostic_head_severity_3 = '',

		-- TODO
		diagnostic_head_description = '👹',
		diagnostic_virtual_text = '🦊',
		diagnostic_file = '🚑',

		-- TODO
		value_changed = '📝',
		value_definition = '🐶🍡', -- it is easier to see than 🦕

		-- TODO
		match_kinds = {
			var = ' ', -- "👹", -- Vampaire
			method = 'ƒ ', --  "🍔", -- mac
			['function'] = ' ', -- "🤣", -- Fun
			parameter = '  ', -- Pi
			associated = '🤝',
			namespace = '🚀',
			type = ' ',
			field = '🏈',
			module = '📦',
			flag = '🎏',
		},
		treesitter_defult = '🌲',
		doc_symbols = '',
	},

	transparency = 100,
}
