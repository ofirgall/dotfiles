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
	require 'illuminate'.on_attach(client)
	require "lsp_signature".on_attach(lsp_signature_cfg)
	require 'nvim-navic'.attach(client, bufnr)
end

local lsp_on_attach_format = function(client, bufnr)
	require('lsp-format').on_attach(client)
	lsp_on_attach(client, bufnr)
end

-- logs at "$HOME/.cache/nvim/lsp.log"
-- vim.lsp.set_log_level("debug")

if not NO_SUDO then
	require 'lspconfig'.pyright.setup {
		on_attach = lsp_on_attach,
		capabilities = capabilities,
	}
else
	require 'lspconfig'.pylsp.setup {
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

require 'lspconfig'.rust_analyzer.setup {
	on_attach = lsp_on_attach_format,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			-- enable clippy on save
			checkOnSave = {
				command = "clippy"
			},
		}
	},
	-- handlers = {
	-- 	["textDocument/publishDiagnostics"] = vim.lsp.with(
	-- 		vim.lsp.diagnostic.on_publish_diagnostics, {
	-- 			-- Enable virtual_text for rust_analyzer
	-- 			virtual_text = true
	-- 		}
	-- 	),
	-- }
}
require 'lspconfig'.bashls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.vimls.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.cmake.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.gopls.setup {
	on_attach = lsp_on_attach_format,
	capabilities = capabilities,
	settings = {
		gopls = {
			-- usePlaceholders = true
		}
	}
}
require 'lspconfig'.cucumber_language_server.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}

local clang_cmd = { "clangd", "--background-index", "--fallback-style=none", "--header-insertion=never",
	"--all-scopes-completion", "--cross-file-rename" }

if vim.fn.has('wsl') == 1 then
	table.insert(clang_cmd, "-j=4") -- Limit resources on wsl
end

if NO_SUDO then
	clang_cmd = { "clangd", "-completion-style=bundled" }
end

require 'lspconfig'.clangd.setup {
	init_options = {
		clangdFileStatus = true
	},
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	cmd = clang_cmd,
}

require('lua-dev').setup {
}

require 'lspconfig'.sumneko_lua.setup {
	on_attach = lsp_on_attach_format,
	capabilities = capabilities,
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
		},
	},
}

require('fidget').setup {
}

require('lsp-format').setup {
}
