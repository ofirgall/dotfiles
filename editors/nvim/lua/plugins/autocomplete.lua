-- dcampos/nvim-snippy
local snippy = require('snippy')
snippy.setup({
	mappings = {
		s = {
			['<Tab>'] = 'next',
			['<S-Tab>'] = 'previous',
		},
		nx = {
			['<Tab>'] = 'next',
			['<S-Tab>'] = 'previous',
		},
	},
})

-- danymat/neogen
local neogen = require('neogen')
neogen.setup {
	enabled = true,
}

-- hrsh7th/nvim-cmp
local cmp = require('cmp')
-- onsails/lspkind-nvim
local lspkind = require('lspkind')

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local function all_visible_buffers_source(priority, max_item_count)
	return {
		name = 'buffer',
		priority = priority,
		option = {
			get_bufnrs = function()
				local bufs = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					bufs[vim.api.nvim_win_get_buf(win)] = true
				end
				return vim.tbl_keys(bufs)
			end,
		},
		max_item_count = max_item_count,
	}
end

-- ofirgall/cmp-lspkind-priority
local compare = require('cmp.config.compare')
local lspkind_priority = require('cmp-lspkind-priority')
lspkind_priority.setup {
	priority = {
		'Module',
		'Variable',
		'Field',
		'Keyword',
		'Snippet',

		'Method',
		'Function',
		'Constructor',
		'Class',
		'Interface',
		'Property',
		'Unit',
		'Value',
		'Enum',
		'Color',
		'File',
		'Reference',
		'Folder',
		'EnumMember',
		'Constant',
		'Struct',
		'Event',
		'Operator',
		'TypeParameter',
		'Text',
	},
}

cmp_setup_dict = {
	snippet = {
		expand = function(args)
			require('snippy').expand_snippet(args.body) -- For `snippy` users.
		end,
	},
	mapping = {
		['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs( -8), { 'i', 'c' }),
		['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(8), { 'i', 'c' }),
		['<C-y>'] = cmp.mapping(cmp.mapping.scroll_docs( -1), { 'i', 'c' }),
		['<C-e>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<CR>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
			else
				fallback()
			end
		end, { 'i' }),
		-- ['<Esc>'] = cmp.mapping(function (fallback)
		-- 	-- if cmp.visible() and snippy.can_jump(1) then
		-- 	if snippy.can_jump(1) then
		-- 		snippy.next()
		-- 	end
		-- 	fallback()
		-- end, { 'i' }),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif snippy.can_jump(1) then
				snippy.next()
			else
				fallback()
			end
		end, { 'i', 'c' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif snippy.can_jump( -1) then
				snippy.previous()
			else
				fallback()
			end
		end, { 'i', 'c' }),
	},
	formatting = {
		format = lspkind.cmp_format({
			symbol_map = require('ofirkai.plugins.nvim-cmp').kind_icons,
			maxwidth = 50,
			mode = 'symbol'
		}),
	},
	window = require('ofirkai.plugins.nvim-cmp').window,
	sources = cmp.config.sources({
		{ name = 'nvim_lsp_signature_help', priority = 1500 },
		{ name = 'nvim_lsp', priority = 1000 },
		{ name = 'path', option = { trailing_slash = true }, priority = 500 },
		{ name = 'snippy', priority = 200 },
		{ name = 'buffer', priority = 100, max_item_count = 5 }, -- local buffer if lsp is valid
		{ name = 'spell', priority = 50, max_item_count = 5 }, -- Spell here because we can toggle it easily
	}, {
		all_visible_buffers_source(150, 15),
		{ name = 'spell', priority = 50, max_item_count = 10 },
	}),
	performance = {
		debounce = 30, -- default: 60
		throttle = 15, -- default: 30
	},
	sorting = {
		comparators = {
			lspkind_priority.compare, -- compare.kind,
			compare.offset,
			compare.exact,
			-- compare.scopes,
			compare.score,
			compare.recently_used,
			compare.locality,
			compare.sort_text,
			compare.length,
			compare.order,
		},

	},
	preselect = cmp.PreselectMode.None, -- Auto select the first item
	experimental = {
		ghost_text = false,
	},
}

cmp.setup(cmp_setup_dict)

cmp.setup.cmdline('/', {
	sources = {
		all_visible_buffers_source(nil, 15),
	},
})

cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path', option = { trailing_slash = true } },
	}, {
		{
			name = 'cmdline',
			option = {
				ignore_cmds = { 'Man', '!' },
			},
		},
	}),
})

cmp.setup.filetype('dap-repl', {
	sources = {
		{ name = 'dap' },
	},
})

cmp.setup.filetype('dapui_watches', {
	sources = {
		all_visible_buffers_source(150, 15),
		{ name = 'dap' },
	},
})

cmp.setup.filetype('gitcommit', {
	sources = {
		{ name = 'git' },
		all_visible_buffers_source(nil, 15),
		{ name = 'spell', max_item_count = 5 },
		-- { name = 'dictionary' }, -- TODO: get a faster dictionary + better
	},
})

cmp.setup.filetype('toml', {
	sources = {
		{ name = 'crates', priority = 500 },
		all_visible_buffers_source(nil, 15),
	},
})

-- ray-x/navigator.lua, No filetypes for guihua
cmp.setup.filetype('guihua', {})
cmp.setup.filetype('guihua_rust', {})

-- add pair when accepting autocomplete
-- windwp/nvim-autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local on_confirm_done_callback = function(evt)
	entry = evt.entry
	-- print(entry.source.name)
	-- if entry.source.name ~= 'snippy' and snippy.can_jump(1) then
	-- 	snippy.next()
	-- else
	-- 	cmp_autopairs.on_confirm_done({ map_char = { tex = '' } })
	-- end
	cmp_autopairs.on_confirm_done({ map_char = { tex = '' } })
end

cmp.event:on('confirm_done', on_confirm_done_callback)

-- petertriho/cmp-git
require('cmp_git').setup {
}

-- uga-rosa/cmp-dictionary
require('cmp_dictionary').setup {
	dic = {
		['*'] = { '/usr/share/dict/words' },
	},
	first_case_insensitive = true,
}
