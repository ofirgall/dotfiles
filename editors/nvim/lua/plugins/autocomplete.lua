local snippy = require("snippy")
snippy.setup({
	mappings = {
		s = {
			["<Tab>"] = "next",
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

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp_completion_design = {
	border = 'rounded',
	winhighlight = 'Normal:Normal,CursorLine:Visual,Search:None',
	zindex = 1001,
}

cmp_setup_dict = {
	snippet = {
		expand = function(args)
			require('snippy').expand_snippet(args.body) -- For `snippy` users.
		end,
	},
	mapping = {
		['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-8), { 'i', 'c' }),
		['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(8), { 'i', 'c' }),
		['<C-y>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
		['<C-e>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<CR>'] = cmp.mapping(function (fallback)
			if cmp.visible() then
				cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
			else
				fallback()
			end
		end, { 'i' }),
		['<Esc>'] = cmp.mapping(function (fallback)
			if snippy.can_jump(1) then
				snippy.next()
			end
			fallback()
		end, { 'i' }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif snippy.can_jump(1) then
				snippy.next()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "c" }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif snippy.can_jump(-1) then
				snippy.previous()
			else
				fallback()
			end
		end, { "i", "c" }),
	},
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
			symbol_map = kind_icons,
			mode = 'symbol'
		})
	},
	window = {
		completion = cmp_completion_design,
		documentation = cmp_completion_design,
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp', priority = 1000 },
		{ name = 'snippy', priority = 100 },
	}, {
		{ name = 'spell' },
		{ name = 'neorg' },
		{ name = 'git' },
		{ name = 'path', option = {trailing_slash = true}},
		{ name = 'buffer' },
	}),
	performance = {
		debounce = 30, -- default: 60
		throttle = 15, -- default: 30
	}
}

cmp.setup(cmp_setup_dict)

cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path', option = {trailing_slash = true}}
	}, {
		{ name = 'cmdline' }
	})
})

cmp.setup.filetype({ 'dap-repl', 'dapui_watches' }, {
	sources = {
		{ name = 'dap' },
	},
})

-- add pair when accepting autocomplet
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local on_confirm_done_callback = function(evt)
	entry = evt.entry
	if entry.source.name ~= 'snippy' and snippy.can_jump(1) then
		snippy.next()
	else
		cmp_autopairs.on_confirm_done({ map_char = { tex = '' } })
	end
end

cmp.event:on('confirm_done', on_confirm_done_callback)

-- LSP SAGA --
vim.diagnostic.config{
	signs = {
		priority = 8
	}
}
require('lspsaga').init_lsp_saga({
	code_action_keys = {
		quit = "<Escape>",
		exec = "<CR>",
	},
	code_action_lightbulb = {
		-- sign_priority = 9,
		sign = false,
		virtual_text = true,
		enable_in_insert  = false
	},
	rename_in_select = false,
})

-- cmp-git
require('cmp_git').setup{
}

-- lsp_lines.nvim
-- Disable builtin diagnostic
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = false
	}
)

require('lsp_lines').setup{
}
