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
		disable = { 'help', 'git_rebase', 'gitcommit', 'comment' }
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
			lookbehind = true,
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
				['aF'] = '@function.name',
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
	},
	-- JoosepAlviste/nvim-ts-context-commentstring
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
		config = {
			query = '; %s'
		}
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
	((true) @cap)
	((false) @cap)
	((attribute) @cap)
]]
local go_query = [[
	;; query
	((selector_expression) @cap) ; Method call
	((field_identifier) @cap) ; Method names in interface

	; Identifiers
	((identifier) @cap)
	((expression_list) @cap) ; pseudo Identifier
	((int_literal) @cap)
	((interpreted_string_literal) @cap)

	; Types
	((type_identifier) @cap)
	((pointer_type) @cap)
	((slice_type) @cap)

	; Keywords
	((true) @cap)
	((false) @cap)
	((nil) @cap)
]]
local rust_query = [[
	;; query
	((boolean_literal) @cap)
	((string_literal) @cap)

	; Identifiers
	((identifier) @cap)
	((field_identifier) @cap)
	((field_expression) @cap)
	((scoped_identifier) @cap)
	((unit_expression) @cap)

	; Types
	((reference_type) @cap)
	((primitive_type) @cap)
	((type_identifier) @cap)
	((generic_type) @cap)

	; Calls
	((call_expression) @cap)
]]
local c_query = [[
	;; query

	((string_literal) @cap)
	((system_lib_string) @cap)

	; Identifiers
	((identifier) @cap)
	((struct_specifier) @cap)
	((type_identifier) @cap)
	((field_identifier) @cap)
	((number_literal) @cap)
	((unary_expression) @cap)
	((pointer_declarator) @cap)

	; Types
	((primitive_type) @cap)

	; Expressions
	(assignment_expression
		right: (_) @cap)
]]
local cpp_query = [[
	;; query

	; Identifiers
	((namespace_identifier) @cap)
]] .. c_query

local queries = {
	lua = lua_query,
	python = python_query,
	go = go_query,
	rust = rust_query,
	c = c_query,
	cpp = cpp_query,
}

map({ 'n', 'x', 'i' }, '<M-k>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'previous',
		vertical_drill_jump = true,
		visual_mode = true,
		fallback = function()
			select_ease.select_node({ queries = queries, direction = 'previous', visual_mode = true })
		end,
	})
end, {})

map({ 'n', 'x', 'i' }, '<M-j>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'next',
		vertical_drill_jump = true,
		visual_mode = true,
		fallback = function()
			select_ease.select_node({ queries = queries, direction = 'next', visual_mode = true })
		end,
	})
end, {})
map({ 'n', 'x', 'i' }, '<M-h>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'previous',
		current_line_only = false,
		visual_mode = true,
	})
end, {})
map({ 'n', 'x', 'i' }, '<M-l>', function()
	select_ease.select_node({
		queries = queries,
		direction = 'next',
		current_line_only = false,
		visual_mode = true,
	})
end, {})

-- previous / next node that matches query
map({ 'n', 'x', 'i' }, '<M-K>', function()
	select_ease.select_node({ queries = queries, direction = 'previous', visual_mode = true })
end, {})
map({ 'n', 'x', 'i' }, '<M-J>', function()
	select_ease.select_node({ queries = queries, direction = 'next', visual_mode = true })
end, {})
