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

local neogen = require('neogen')
neogen.setup {
	enabled = true
}

local cmp = require'cmp'
local lspkind = require('lspkind')

local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = ""
}

cmp_setup_dict = {
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
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<C-y>'] = cmp.config.disable,
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
			symbol_map = kind_icons,
			mode = 'symbol'
		})
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'snippy' },
		{ name = 'spell' },
	}, {
		{ name = 'buffer' },
	})
}

cmp.setup(cmp_setup_dict)

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

require('lspsaga').setup({
	code_action_keys = {
		quit = "<Escape>",
		exec = "<CR>",
	},
	rename_action_keys = {
		quit = "<C-c>",
		exec = "<CR>",
	},
})
