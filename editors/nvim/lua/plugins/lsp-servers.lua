-- neovim/nvim-lspconfig
local lspconfig = require('lspconfig')

-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.window.workDoneProgress = true

local lsp_signature_cfg = {
	bind = true,
	use_lspsaga = false,
	doc_lines = 0,
	floating_window = false,
	hint_scheme = 'LspSignatureHintVirtualText',
	hint_prefix = ' ',
}

local lsp_on_attach = function(client, bufnr)
	-- RRethy/vim-illuminate
	require 'illuminate'.on_attach(client)
	-- ray-x/lsp_signature.nvim
	require 'lsp_signature'.on_attach(lsp_signature_cfg)
	-- SmiteshP/nvim-navic
	require 'nvim-navic'.attach(client, bufnr)
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
lspconfig.gopls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		gopls = {
			usePlaceholders = true
		}
	}
}
lspconfig.cucumber_language_server.setup {
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

-- folke/lua-dev.nvim
require('lua-dev').setup {
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

-- j-hui/fidget.nvim
require('fidget').setup {
}

-- ofirgall/format-on-leave.nvim
require('format-on-leave').setup {
	pattern = { '*.rs', '*.go' }
}
