if vim.g.started_by_firenvim then
	do return end
end

-----------------------------------------------------------
-- Tree Sitter
-----------------------------------------------------------

if IS_REMOTE then
	ignore_install_langs = { 'norg', 'foam', 'haskell' }
else
	ignore_install_langs = {}
end

require('nvim-treesitter.configs').setup {
	ensure_installed = 'all',
	sync_install = false,
	ignore_install = ignore_install_langs,
	highlight = {
		enable = true,
		disable = { 'help', 'git_rebase', 'gitcommit' }
	},
	indent = {
		enable = true
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<CR>',
			node_incremental = '<CR>',
			scope_incremental = '<S-CR>',
			node_decremental = '<BS>',
		},
	},
	-- yati = { enable = true },
	-- nvim-treesitter/nvim-treesitter-textobjects
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				[']m'] = '@function.outer',
				[']]'] = '@class.outer',
				[']b'] = '@block.outer',
				[']a'] = '@parameter.inner',
				[']k'] = '@call.outer',
			},
			goto_next_end = {
				[']M'] = '@function.outer',
				[']['] = '@class.outer',
				[']B'] = '@block.outer',
				[']A'] = '@parameter.inner',
				[']K'] = '@call.outer',
			},
			goto_previous_start = {
				['[m'] = '@function.outer',
				['[['] = '@class.outer',
				['[b'] = '@block.outer',
				['[a'] = '@parameter.inner',
				['[k'] = '@call.inner',
			},
			goto_previous_end = {
				['[M'] = '@function.outer',
				['[]'] = '@class.outer',
				['[B'] = '@block.outer',
				['[A'] = '@parameter.inner',
				['[K'] = '@call.inner',
			},
		},
		select = {
			enable = true,
			lookahead = true,
			-- include_surrounding_whitespace = true,
			keymaps = {
				['af'] = '@function.outer',
				['if'] = '@function.inner',
				['ac'] = '@class.outer',
				['ic'] = '@class.inner',
				['ab'] = '@block.outer',
				['ib'] = '@block.inner',
				['aL'] = '@loop.outer', -- `al` is already in used by `a line`
				['iL'] = '@loop.inner', -- same as `al`
				['a/'] = '@comment.outer',
				['i/'] = '@comment.outer', -- no inner for comment
				['aa'] = '@parameter.outer', -- parameter -> argument
				['ia'] = '@parameter.inner',
				['ak'] = '@call.outer',
				['ik'] = '@call.inner',
				['ai'] = '@conditional.outer', -- i as if
				['ii'] = '@conditional.inner',

				-- Custom captures
				['ie'] = '@binary_expression.inner',
			},
		},
	},
	-- andymass/vim-matchup
	matchup = {
		enable = true
	},
	-- mrjones2014/nvim-ts-rainbow
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" },
		extended_mode = false,
		max_file_lines = nil,
		colors = {
			-- '#ff3429',
			'#ff647e',
			'#ff57d5',
			'#ffd121',
			'#68dd6a',
			'#ff880e',
			'#41a2ac',
			'#26cca0'
		},
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	}
}

-- ziontee113/SelectEase
local select_ease = require("SelectEase")
local lua_query = [[
			;; query
			((identifier) @cap)
			("string_content" @cap)
			((true) @cap)
			((false) @cap)
			]]
local python_query = [[
			;; query
			((identifier) @cap)
			((string) @cap)
			]]

local queries = {
	lua = lua_query,
	python = python_query,
}

map({ 'n', 's', 'i' }, '<M-k>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'previous',
		vertical_drill_jump = true,
	})
end, {})
map({ 'n', 's', 'i' }, '<M-j>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'next',
		vertical_drill_jump = true,
	})
end, {})
map({ 'n', 's', 'i' }, '<M-h>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'previous',
		current_line_only = true,
	})
end, {})
map({ 'n', 's', 'i' }, '<M-l>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'next',
		current_line_only = true,
	})
end, {})

-- previous / next node that matches query
map({ 'n', 's', 'i' }, '<M-K>', function()
	select_ease.select_node({ queries = queries, direction = 'previous' })
end, {})
map({ 'n', 's', 'i' }, '<M-J>', function()
	select_ease.select_node({ queries = queries, direction = 'next' })
end, {})
