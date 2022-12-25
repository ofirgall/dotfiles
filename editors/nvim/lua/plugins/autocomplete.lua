-- dcampos/nvim-snippy
local snippy = require('snippy')
snippy.setup({
	mappings = {
		s = {
			['<Tab>'] = 'next',
			['<S-Tab>'] = 'previous',
		},
		nx = {
			['<leader>x'] = 'cut_text',
			['<Tab>'] = 'next',
			['<S-Tab>'] = 'previous',
		},
	},
})

-- danymat/neogen
local neogen = require('neogen')
neogen.setup {
	enabled = true
}

-- hrsh7th/nvim-cmp
local cmp = require('cmp')
-- onsails/lspkind-nvim
local lspkind = require('lspkind')

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local function all_visible_buffers_source(priority)
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
			end
		}
	}
end

local types = require('cmp.types')
local compare = require('cmp.types')

local kind_compare = function(entry1, entry2)
	local kind1 = entry1:get_kind()
	kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
	local kind2 = entry2:get_kind()
	kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
	if kind1 ~= kind2 then
		if kind1 == types.lsp.CompletionItemKind.Snippet or kind1 == types.lsp.CompletionItemKind.Variable then
			return true
		end
		if kind1 == types.lsp.CompletionItemKind.Snippet or kind1 == types.lsp.CompletionItemKind.Variable then
			return false
		end
		local diff = kind1 - kind2
		if diff < 0 then
			return true
		elseif diff > 0 then
			return false
		end
	end
end

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
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { 'i', 'c' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif snippy.can_jump(-1) then
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
		})
	},
	window = require('ofirkai.plugins.nvim-cmp').window,
	sources = cmp.config.sources({
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'nvim_lsp', priority = 1000 },
		{ name = 'path', option = { trailing_slash = true }, priority = 500 },
		{ name = 'snippy', priority = 200 },
		all_visible_buffers_source(150),
		{ name = 'spell', priority = 50 }, -- Spell here because we can toggle it easily
	}),
	performance = {
		debounce = 30, -- default: 60
		throttle = 15, -- default: 30
	},
	sorting = {
		comparators = {
			compare.offset,
			compare.exact,
			-- compare.scopes,
			compare.score,
			compare.recently_used,
			compare.locality,
			kind_compare, -- compare.kind,
			compare.sort_text,
			compare.length,
			compare.order,
		},

	},
	preselect = cmp.PreselectMode.None, -- Auto select the first item

	experimental = {
		ghost_text = false
	},
}

cmp.setup(cmp_setup_dict)

cmp.setup.cmdline('/', {
	sources = {
		all_visible_buffers_source(nil),
	}
})

cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path', option = { trailing_slash = true } }
	}, {
		{ name = 'cmdline' }
	})
})

cmp.setup.filetype({ 'dap-repl', 'dapui_watches' }, {
	sources = {
		{ name = 'dap' },
	},
})

cmp.setup.filetype('gitcommit', {
	sources = {
		{ name = 'git' },
		all_visible_buffers_source(nil),
		-- { name = 'dictionary' }, -- TODO: get a faster dictionary + better
	}
})

cmp.setup.filetype('toml', {
	sources = {
		{ name = 'crates', priority = 500 },
		all_visible_buffers_source(nil),
	}
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
		["*"] = { "/usr/share/dict/words" },
	},
	first_case_insensitive = true,
}
