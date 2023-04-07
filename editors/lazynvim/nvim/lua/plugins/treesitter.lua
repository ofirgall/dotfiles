local M = {}

table.insert(M, {
	'nvim-treesitter/nvim-treesitter',
	version = false, -- last release is way too old
	build = ':TSUpdate',
	event = { 'BufReadPost', 'BufNewFile' },
	keys = {
		{ '<CR>', desc = 'Increment selection' },
		{ '<BS>', desc = 'Decrement selection', mode = 'x' },
	},
	---@type TSConfig
	opts = {
		ensure_installed = 'all',
		sync_install = false,
		ignore_install = { 'help', 'git_rebase', 'gitcommit', 'comment' },
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
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
			enable = true,
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
			},
		},

	},
	---@param opts TSConfig
	config = function(_, opts)
		require('nvim-treesitter.configs').setup(opts)
	end,
})

table.insert(M, {
	'nvim-treesitter/nvim-treesitter-textobjects',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
})

table.insert(M, {
	'nvim-treesitter/nvim-treesitter-context',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
})

table.insert(M, {
	'JoosepAlviste/nvim-ts-context-commentstring',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
})

table.insert(M, {
	'andymass/vim-matchup',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
	init = function()
		-- Disable matchup higlights, use the default of vim
		vim.api.nvim_create_autocmd('FileType', {
			pattern = '*',
			callback = function()
				vim.b.matchup_matchparen_enabled = 0
			end,
		})
	end,
})

return M
