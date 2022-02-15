-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.window.workDoneProgress = true

local lsp_signature_cfg = {
	bind = true,
	use_lspsaga = true,
	doc_lines = 0,
	toggle_key = '<M-x>',
	max_height = 1,
}

local lsp_on_attach = function(client)
	require 'illuminate'.on_attach(client)
	require "lsp_signature".on_attach(lsp_signature_cfg)
end,

require "lsp_signature".setup({lsp_signature_cfg})

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local is_remote = file_exists(os.getenv("HOME") .. "/.remote_indicator")

-- logs at "$HOME/.cache/nvim/lsp.log"
-- vim.lsp.set_log_level("debug")

if not is_remote then
	require'lspconfig'.pyright.setup{
		on_attach = lsp_on_attach,
		capabilities = capabilities,
	}
else
	require'lspconfig'.pylsp.setup{
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

require'lspconfig'.rust_analyzer.setup{
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
require'lspconfig'.bashls.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require'lspconfig'.vimls.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require'lspconfig'.cmake.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}

local clang_cmd = { "clangd", "--background-index", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"}
-- local clang_cmd = { "clangd", "--background-index=false", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"}

if is_remote then
	clang_cmd = { "clangd", "-completion-style=bundled" }
end

require'lspconfig'.clangd.setup{
	init_options = {
	    clangdFileStatus = true
	},
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	cmd = clang_cmd,
}
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.sumneko_lua.setup {
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = runtime_path,
			},
			diagnostics = {
				globals = {'vim'},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

require"fidget".setup{}