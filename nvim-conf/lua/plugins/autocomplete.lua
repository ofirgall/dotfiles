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

-- LSP SAGA --
-- Disable builtin diagnostic
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

require('lspsaga').setup {}
