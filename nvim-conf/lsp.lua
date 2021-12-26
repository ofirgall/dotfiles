local map = vim.api.nvim_set_keymap

-- Update capabilities to autocomplete
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- vim.lsp.set_log_level("debug")
require'lspconfig'.pyright.setup{
	capabilities = capabilities,
}
require'lspconfig'.rust_analyzer.setup{
	capabilities = capabilities,
}
require'lspconfig'.bashls.setup{
	capabilities = capabilities,
}
require'lspconfig'.clangd.setup{
	on_attach = function(client)
      require 'illuminate'.on_attach(client)
    end,
	capabilities = capabilities,
	cmd = { "clangd", "--background-index", "--fallback-style=none", "--header-insertion=never", "--all-scopes-completion", "--cross-file-rename"},
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
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {silent = true, noremap = true})
map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {silent = true, noremap = true})

-- Telescope LSP Binds --
map('n', 'gd', "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>", {silent = true, noremap = true})
map('n', 'gi', "<cmd>lua require'telescope.builtin'.lsp_implementations{}<CR>", {silent = true, noremap = true})

map('n', 'gs', "<cmd>lua require'telescope.builtin'.lsp_document_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gS', "<cmd>lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gr', "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>", {silent = true, noremap = true})

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
