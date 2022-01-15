local lsp_status = require('lsp-status')

-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)

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
	lsp_status.on_attach(client)
end,

require "lsp_signature".setup({lsp_signature_cfg})

-- logs at "$HOME/.cache/nvim/lsp.log"
-- vim.lsp.set_log_level("debug")

require'lspconfig'.pyright.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}

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

-- local clang_cmd = { "clangd", "--background-index", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"}
local clang_cmd = { "clangd", "--background-index=false", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if file_exists(os.getenv("HOME") .. "/.remote_indicator") then
	clang_cmd = { "clangd", "-completion-style=bundled" }
end

require'lspconfig'.clangd.setup{
	handlers = lsp_status.extensions.clangd.setup(),
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

lsp_status.config({
  current_function = false,
  show_filename = false,
  diagnostics = false,
  status_symbol = 'V',
})
lsp_status.register_progress()
