HYDRAS['Goto funcs'] = {
	hint = [[
 _j_ _J_ : up
 _k_ _K_ : down
  _<Esc>_
	]],
	config = {
		timeout = 4000,
		hint = {
			border = 'rounded'
		},
	},
	mode = { 'n', 'x' },
	heads = {
		{ 'j', function()
			require('nvim-treesitter.textobjects.move').goto_next_start('@function.name')
			require('utils.misc').center_screen()
		end, },
		{ 'J', function()
			require('nvim-treesitter.textobjects.move').goto_next_end('@function.outer')
			require('utils.misc').center_screen()
		end, },
		{ 'k', function()
			require('nvim-treesitter.textobjects.move').goto_previous_start('@function.name')
			require('utils.misc').center_screen()
		end, },
		{ 'K', function()
			require('nvim-treesitter.textobjects.move').goto_previous_end('@function.outer')
			require('utils.misc').center_screen()
		end, },
		--
		{ '<Esc>', nil, { exit = true } },
	},
	custom_bodies = {
		{
			'gj',
			mode = { 'n', 'x' },
			desc = 'Go down a function',
			callback = function(hydra)
				require('nvim-treesitter.textobjects.move').goto_next_start('@function.name')
				require('utils.misc').center_screen()
				hydra:activate()
			end,
		},
		{
			'gk',
			mode = { 'n', 'x' },
			desc = 'Go up a function',
			callback = function(hydra)
				require('nvim-treesitter.textobjects.move').goto_previous_start('@function.name')
				require('utils.misc').center_screen()
				hydra:activate()
			end,
		},
		{
			'gJ',
			mode = { 'n', 'x' },
			desc = 'Go down to an end of a function',
			callback = function(hydra)
				require('nvim-treesitter.textobjects.move').goto_next_end('@function.outer')
				require('utils.misc').center_screen()
				hydra:activate()
			end,
		},
		{
			'gK',
			mode = { 'n', 'x' },
			desc = 'Go up to an end of a function',
			callback = function(hydra)
				require('nvim-treesitter.textobjects.move').goto_previous_end('@function.outer')
				require('utils.misc').center_screen()
				hydra:activate()
			end,
		},
	},
}

return {}
