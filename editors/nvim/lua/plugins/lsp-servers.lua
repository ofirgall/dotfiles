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
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			-- enable clippy on save
			checkOnSave = {
				command = "clippy"
			},
		}
	},
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
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		gopls = {
			usePlaceholders = true
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

require('fidget').setup {
}

local auto_format_cmd = -1
local auto_format_cmd_save = -1
local auto_format_patterns = { '*.lua', '*.rs', '*.go' }
local buffers_in_format = {}

local disable_auto_format = function()
	if auto_format_cmd ~= -1 then
		vim.api.nvim_del_autocmd(auto_format_cmd)
		auto_format_cmd = -1
	end

	if auto_format_cmd_save ~= -1 then
		vim.api.nvim_del_autocmd(auto_format_cmd_save)
		auto_format_cmd_save = -1
	end
end

local enable_auto_format = function()
	disable_auto_format()

	auto_format_cmd = vim.api.nvim_create_autocmd('BufLeave', {
		pattern = auto_format_patterns,
		callback = function(params)
			if #vim.lsp.get_active_clients({ bufnr = params.buf }) > 0 then
				-- TODO: change to async true if you can write after sync
				vim.lsp.buf.format({ bufnr = params.buf, async = false })
				vim.cmd("silent! write")
				-- table.insert(buffers_in_format, params.buf)
			end
		end
	})

	-- auto_format_cmd_save = vim.api.nvim_create_autocmd('FileWritePost', {
	-- 	pattern = auto_format_patterns,
	-- 	callback = function(params)
	-- 		vim.pretty_print(params)
	-- 		-- for _, bufnr in ipairs(buffers_in_format) do
	-- 		-- 	if params.buf == bufnr then
	-- 		-- 		vim.cmd('slient! write')
	-- 		-- 		break
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- })
end

vim.api.nvim_create_user_command('FormatEnable', enable_auto_format, {})
vim.api.nvim_create_user_command('FormatDisable', disable_auto_format, {})
enable_auto_format()
