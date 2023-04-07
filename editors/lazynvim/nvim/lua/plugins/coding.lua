local M = {}
-- Plugins you interact by actual coding

local api = vim.api

table.insert(M, {
	'numToStr/Comment.nvim',
	event = { 'BufReadPre', 'BufNewFile' },
	config = function()
		require('Comment').setup {

			pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
		}
	end,
	dependencies = {
		'JoosepAlviste/nvim-ts-context-commentstring',
	},
})

table.insert(M, {
	'windwp/nvim-autopairs',
	event = { 'InsertEnter' },
	config = function()
		require('nvim-autopairs').setup {
			check_ts = true,
			disable_filetype = { 'TelescopePrompt', 'guihua', 'guihua_rust', 'clap_input' },
			-- enable_moveright = false,
		}
	end,
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
})

table.insert(M, {
	'nacro90/numb.nvim',
	event = 'CmdLineEnter',
	config = function()
		require('numb').setup {
			number_only = true,
		}
	end,
})

table.insert(M, {
	'ggandor/leap.nvim',
	config = function()
		require('leap').setup {
			max_aot_targets = nil,
			highlight_unlabeled = false,
		}
	end,
	keys = {
		{ '<leader>s', '<Plug>(leap-forward)', mode = { 'n', 'x' }, desc = 'Leap forward' },
		{ '<leader>S', '<Plug>(leap-backward)', mode = { 'n', 'x' }, desc = 'Leap backard' },

	},
})

table.insert(M, {
	'ggandor/flit.nvim',
	dependencies = {
		'ggandor/leap.nvim'
	},
	config = function()
		require('flit').setup {
			labeled_modes = 'nv',
		}
	end,
	keys = { 'f', 'F', 't', 'T' },
})

table.insert(M, {
	'andrewferrier/debugprint.nvim',
	config = function()
		require('debugprint').setup {
			print_tag = '--- DEBUG PRINT ---'
		}
	end,
	keys = { 'g?p', 'g?P', 'g?v', 'g?V' },
	cmd = 'DeleteDebugPrints'
})

table.insert(M, {
	'nguyenvukhang/nvim-toggler',
	config = function()
		require('nvim-toggler').setup {
			inverses = {
				['to'] = 'from',
				['failed'] = 'succeeded',
				['before'] = 'after',
			},
			remove_default_keybinds = true,
		}
	end,
	keys = {
		{
			'<leader>i',
			function() require('nvim-toggler').toggle() end,
			mode = { 'n', 'v' },
			desc = 'Invert words',
		},

	},
})


local text_case_cmd_table = {
	['UpperCase'] = 'to_upper_case',
	['LowerCase'] = 'to_lower_case',
	['SnakeCase'] = 'to_snake_case',
	['ConstantCase'] = 'to_dash_case',
	['DashCase'] = 'to_constant_case',
	['DotCase'] = 'to_dot_case',
	['CamelCase'] = 'to_camel_case',
	['PascalCase'] = 'to_pascal_case',
	['TitleCase'] = 'to_title_case',
	['PathCase'] = 'to_path_case',
	['PhraseCase'] = 'to_phrase_case',
}

local text_case_cmds = {}

for key, _ in pairs(text_case_cmd_table) do
	table.insert(text_case_cmds, key)
end

table.insert(M, {
	'johmsalas/text-case.nvim',
	cmd = text_case_cmds,
	config = function()
		local textcase = require('textcase')
		textcase.setup {
		}

		for usrcmd, apiname in pairs(text_case_cmd_table) do
			api.nvim_create_user_command(usrcmd, function() textcase.current_word(apiname) end, {})
		end
	end,
})

table.insert(M, {
	'gbprod/yanky.nvim',
	config = function()
		require('yanky').setup {
			system_clipboard = {
				sync_with_ring = false,
			},
			highlight = {
				on_put = false,
				on_yank = false,
			},
		}
	end,
	keys = {
		{ 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank with yanky.nvim' },
		{ 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Paste with yanky.nvim' },
		{ 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Paste with yank.nvim' },
		{ '<leader>p', '"_d<Plug>(YankyPutBefore)', mode = 'x', desc = 'replace text without changing the copy register' },
		{ '<M-[>', '<Plug>(YankyCycleForward)', desc = 'Cycle yank history forward' },
		{ '<M-]>', '<Plug>(YankyCycleBackward)', desc = 'Cycle yank history backward' },
	},
})

table.insert(M, {
	'kylechui/nvim-surround',
	keys = {
		'sa', 's', 'S', 'sd', 'sr', 'srq',

		{ 'sw', 'saiw', desc = 'Surround word', remap = true },
		{ 'sW', 'saiW', desc = 'Surround WORD', remap = true },

		-- Brackets
		{ '<leader>(', 'srB(', desc = 'Replace surround to (', remap = true },
		{ '<leader>{', 'srB{', desc = 'Replace surround to {', remap = true },
		{ '<leader>[', 'srB[', desc = 'Replace surround to [', remap = true },

		-- strings
		{ "<leader>'", "srq'", desc = "Replace surround to '", remap = true },
		{ '<leader>"', 'srq"', desc = 'Replace surround to "', remap = true },
		{ '<leader>`', 'srq`', desc = 'Replace surround to `', remap = true },
	},
	config = function()
		-- switch the surround direction behavior
		local surrounds = require('nvim-surround.config').default_opts.surrounds
		local switched_surrounds = {
			{ '{', '}' },
			{ '(', ')' },
			{ '[', ']' },
			{ '<', '>' },
		}
		for _, pair in ipairs(switched_surrounds) do
			local tmp = surrounds[pair[1]]
			surrounds[pair[1]] = surrounds[pair[2]]
			surrounds[pair[2]] = tmp
		end

		require('nvim-surround').setup {
			keymaps = {
				normal = 'sa',
				normal_cur = false,
				normal_line = false,
				normal_cur_line = false,
				visual = 's',
				visual_line = 'S',
				delete = 'sd',
				change = 'sr',
			},
			aliases = {
				['i'] = '[', -- Index
				['r'] = '(', -- Round
				['b'] = '{', -- Brackets
				['B'] = { '{', '(', '[' },
			},
			surrounds = surrounds,
			move_cursor = false,
		}
	end,
})


table.insert(M, {
	'Wansmer/treesj',
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
	config = function()
		require('treesj').setup {
			use_default_keymaps = false,
		}
	end,
	keys = {
		{ 'sJ', '<cmd>TSJSplit<cr>', desc = 'Splitjoin Split line' },
		{ 'sj', '<cmd>TSJJoin<cr>', desc = 'Splitjoin Join line' },
	},
})

table.insert(M, {
	'Wansmer/sibling-swap.nvim',
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},
	config = function()
		require('sibling-swap').setup {
			use_default_keymaps = false,
		}
	end,
	keys = {
		{ '<C-Right>', function() require('sibling-swap').swap_with_right() end },
		{ '<C-Left>', function() require('sibling-swap').swap_with_left() end },
		{ '<space><Right>', function() require('sibling-swap').swap_with_right_with_opp() end },
		{ '<space><Left>', function() require('sibling-swap').swap_with_left_with_opp() end },
	},
})

-- TODO: might be able to lazy load with the keys
table.insert(M, {
	'chrisgrieser/nvim-various-textobjs',
	keys = {
		-- Default mappings
		{ 'ii', mode = { 'o', 'x' } },
		{ 'ai', mode = { 'o', 'x' } },
		{ 'aI', mode = { 'o', 'x' } },
		{ 'iI', mode = { 'o', 'x' } },
		{ 'R', mode = { 'o', 'x' } },
		{ '%', mode = { 'o', 'x' } },
		{ 'r', mode = { 'o', 'x' } },
		{ 'gG', mode = { 'o', 'x' } },
		{ 'n', mode = { 'o', 'x' } },
		{ '_', mode = { 'o', 'x' } },
		{ 'iv', mode = { 'o', 'x' } },
		{ 'av', mode = { 'o', 'x' } },
		{ 'ik', mode = { 'o', 'x' } },
		{ 'ak', mode = { 'o', 'x' } },
		{ 'L', mode = { 'o', 'x' } },
		{ '!', mode = { 'o', 'x' } },
		{ 'il', mode = { 'o', 'x' } },
		{ 'al', mode = { 'o', 'x' } },

		-- Override "sentence" textobj in favor of subword
		{ 'is', function() require('various-textobjs').subword(true) end, mode = { 'o', 'x' } },
		{ 'as', function() require('various-textobjs').subword(false) end, mode = { 'o', 'x' } },

		{ 'i|', function() require('various-textobjs').shellPipe(true) end, mode = { 'o', 'x' } },
		{ 'a|', function() require('various-textobjs').shellPipe(false) end, mode = { 'o', 'x' } },
	},
	config = function()
		require('various-textobjs').setup {
			useDefaultKeymaps = true,
		}
	end,
})


return M
