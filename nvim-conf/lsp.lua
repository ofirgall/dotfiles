local map = vim.api.nvim_set_keymap

-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local lsp_signature_cfg = {
	bind = true,
	use_lspsaga = true,
}

local lsp_on_attach = function(client)
	require 'illuminate'.on_attach(client)
	require "lsp_signature".on_attach(lsp_signature_cfg)
end,

require "lsp_signature".setup({lsp_signature_cfg})

-- logs at "$HOME/.cache/nvim/lsp.log"
-- vim.lsp.set_log_level("debug")

-- works slower than pyright but working with python2
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

-- require'lspconfig'.pyright.setup{
-- 	on_attach = lsp_on_attach,
-- 	capabilities = capabilities,
-- }

require'lspconfig'.rust_analyzer.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
}
require'lspconfig'.bashls.setup{
	on_attach = lsp_on_attach,
	capabilities = capabilities,
	filetypes = { "sh" },
}

local clang_cmd = { "clangd", "--background-index", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if file_exists(os.getenv("HOME") .. "/.remote_indicator") then
	clang_cmd = { "clangd", "-completion-style=bundled" }
end

require'lspconfig'.clangd.setup{
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

local snippy = require("snippy")
snippy.setup({
    mappings = {
        is = {
            ["<Tab>"] = "expand_or_advance",
            ["<S-Tab>"] = "previous",
        },
        nx = {
            ["<leader>x"] = "cut_text",
        },
    },
})

local cmp = require'cmp'
local lspkind = require('lspkind')
cmp.setup({
	snippet = {
		expand = function(args)
			require('snippy').expand_snippet(args.body) -- For `snippy` users.
		end,
	},
	mapping = {
		['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
		['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<C-y>'] = cmp.config.disable,
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
	formatting = {
		format = lspkind.cmp_format({
			with_text = false,
			maxwidth = 50,
			before = function (entry, vim_item)
				return vim_item
			end
		})
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'snippy' },
	}, {
		{ name = 'buffer' },
	})
})

cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

-- Builtin LSP Binds --
-- map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {silent = true, noremap = true})
map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {silent = true, noremap = true})

-- Telescope LSP Binds --
map('n', 'gd', "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>", {silent = true, noremap = true})
map('n', 'gi', "<cmd>lua require'telescope.builtin'.lsp_implementations{}<CR>", {silent = true, noremap = true})

map('n', 'gs', "<cmd>lua require'telescope.builtin'.lsp_document_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gS', "<cmd>lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gr', "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>", {silent = true, noremap = true})
map('n', 'gp', "<cmd>lua require'telescope.builtin'.diagnostics{bufnr=0}<CR>", {silent = true, noremap = true})
map('n', 'gP', "<cmd>lua require'telescope.builtin'.diagnostics{}<CR>", {silent = true, noremap = true})

-- illumante --
map('n', '<C-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', {noremap=true})
map('n', '<C-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', {noremap=true})

-- LSP SAGA --
-- Disable builtin diagnostic
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

local lspsaga = require 'lspsaga'
lspsaga.setup {}

map("n", "<F2>", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
map("n", "<F4>", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
map("n", "gx", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
map("x", "gx", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
map("n", "<S-Space>",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
map("n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
map("n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
map("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", {silent = true, noremap = true})
map("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", {silent = true, noremap = true})
map("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", {})
map("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", {})
