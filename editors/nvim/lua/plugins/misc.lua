local api = vim.api

-- numToStr/Comment.nvim
require('Comment').setup {
	pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}

-- windwp/nvim-autopairs
require('nvim-autopairs').setup {
	check_ts = true,
	disable_filetype = { 'TelescopePrompt', 'guihua', 'guihua_rust', 'clap_input' },
	-- enable_moveright = false,
}

-- rmagatti/auto-session
require('auto-session').setup {
	log_level = 'error',
	auto_session_suppress_dirs = { '~/', '~/workspace', '~/Downloads', '/', '~/logs' },
	auto_session_use_git_branch = true,

	-- trailblazer
	post_save_cmds = {
		function()
			require('trailblazer').save_trailblazer_state_to_file()
		end
	},
	post_restore_cmds = {
		function()
			require('trailblazer').load_trailblazer_state_from_file()
		end
	},
}

-- Pocco81/auto-save.nvim
local autosave = require('autosave')
autosave.setup {
	clean_command_line_interval = 1000,
	on_off_commands = true,
	execution_message = '',
}

autosave.hook_before_actual_saving = function()
	-- Ignore RaafatTurki/hex.nvim
	if vim.b.hex then
		vim.g.auto_save_abort = true
		return
	end

	mode = vim.api.nvim_get_mode()
	if mode.mode ~= 'n' then -- Don't save while we in insert/select mode (triggered with autopair and such)
		vim.g.auto_save_abort = true
		return
	end
end

-- ethanholz/nvim-lastplace
require('nvim-lastplace').setup {
	lastplace_ignore_buftype = { 'terminal' }
}

-- michaelb/sniprun
require 'sniprun'.setup {
	display = {
		'Classic'
	}
}

-- nacro90/numb.nvim
require('numb').setup {
	number_only = true,
}

-- lyokha/vim-xkbswitch
vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
]])

-- ojroques/vim-oscyank
if IS_REMOTE then
	-- Enable osc(remote) yank
	vim.cmd([[
	autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankReg +' | endif
	]])
end

-- mbbill/undotree
vim.g.undotree_WindowLayout = 3 -- undotree at right

-- gennaro-tedesco/nvim-peekup
local peekup_config = require('nvim-peekup.config')
peekup_config.on_keystroke['delay'] = ''
peekup_config.on_keystroke['autoclose'] = true
peekup_config.on_keystroke['paste_reg'] = '"'

-- akinsho/toggleterm.nvim
-- TODO: fix this annoying bug
--		reproduce:	1. Open terminal (C-t)
--					2. Split it (M-e) twice
--					3. Close all (M-q) * 3
--					4. Reopen terminal, will show term2 instead of 1 and continue to create term2
local toggle_term = require('toggleterm')
toggle_term.setup {
	open_mapping = [[<Nop>]],
	insert_mappings = false,
	terminal_mappings = false,
	direction = 'horizontal',
	size = 20,
	shade_terminals = false,
	highlights = {
		Normal = {
			guibg = '#000000',
			guifg = '#ffffff',
		}
	}
}

local terms = require('toggleterm.terminal')

toggle_or_open_terminal = function(direction)
	-- print("toggle " .. #terms.get_all() .. " hidden " .. #terms.get_all(true))
	if #terms.get_all() == 0 then
		open_new_terminal(direction)
	else
		toggle_term.toggle_all(true)
	end
end

open_new_terminal = function(direction)
	-- Flip directions...
	if direction == 'horizontal' then
		direction = 'vertical'
	else
		direction = 'horizontal'
	end
	local ft = api.nvim_buf_get_option(0, 'filetype')
	local dir = vim.fn.expand('%:p:h')
	if ft == 'toggleterm' then
		-- TODO: this should open in the same dir as the term but it doesn't work
		dir = string.gsub(string.gsub(vim.fn.expand('%:h:h:h'), 'term://', ''), '//.+', '')
	end

	local term = terms.Terminal:new({ id = #terms.get_all() + 1, dir = dir, direction = direction })
	term:open(nil, direction, true)
end

-- chomosuke/term-edit.nvim
require('term-edit').setup {
	prompt_end = '%$ ',
}

-- NMAC427/guess-indent.nvim
require('guess-indent').setup {}

-- szw/vim-maximizer
vim.g.maximizer_default_mapping_key = '<M-Z>'

-- shivamashtikar/tmuxjump.vim
vim.g.tmuxjump_telescope = true
vim.g.tmuxjump_custom_capture = '~/dotfiles_scripts/inner/_tmuxjump_capture.sh'

-- folke/todo-comments.nvim
require('todo-comments').setup {
	signs = false,
	highlight = {
		before = '',
		keyword = 'fg',
		after = ''
	},
	colors = {
		error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
		warning = { '@text.danger', 'DiagnosticWarning', 'WarningMsg', '#FBBF24' },
		info = { '@text.warning', 'DiagnosticInfo', '#2563EB' },
		hint = { '@text.note', 'DiagnosticHint', '#10B981' },
		default = { '@text.note', '#7C3AED' },
	},
}

-- hkupty/iron.nvim
require('iron.core').setup {
	config = {
		should_map_plug = false,
		scratch_repl = true,
		close_window_on_exit = true,
		repl_definition = {
			sh = {
				command = { 'zsh' }
			},
			python = {
				command = { 'ipython3' }
			}
		},
		repl_open_cmd = 'belowright 15 split',
	},
	-- keymaps = {
	-- 	send_motion = '<space>sc',
	-- 	visual_send = '<space>sc',
	-- 	send_file = '<space>sf',
	-- 	send_line = '<space>sl',
	-- 	cr = '<space>s<cr>',
	-- 	interrupt = '<space>s<space>',
	-- 	exit = '<space>sq',
	-- 	clear = '<space>cl',
	-- },
	highlight = {
		italic = false,
		bold = false
	}
}

api.nvim_create_user_command('IPython', function()
	require('iron.core').repl_for('python')
	require('iron.core').focus_on('python')
	api.nvim_feedkeys('i', 'n', false)
end, {})

api.nvim_create_user_command('Lua', function()
	require('iron.core').repl_for('lua')
	require('iron.core').focus_on('lua')
	api.nvim_feedkeys('i', 'n', false)
end, {})

-- norcalli/nvim-colorizer.lua
require('colorizer').setup {
	'*'
}

-- ziontee113/color-picker.nvim
require('color-picker').setup {
}

-- toppair/peek.nvim
require('peek').setup {
}
vim.api.nvim_create_user_command('MarkdownPreviewOpen', require('peek').open, {})
vim.api.nvim_create_user_command('MarkdownPreviewClose', require('peek').close, {})

-- ggandor/leap.nvim
require('leap').setup {
	max_aot_targets = nil,
	highlight_unlabeled = false,
}

-- ggandor/flit.nvim
require('flit').setup {
	labeled_modes = 'nv',
}

-- tiagovla/scope.nvim
require('scope').setup {
}

-- andrewferrier/debugprint.nvim
require('debugprint').setup {
	print_tag = '--- DEBUG PRINT ---'
}

-- nguyenvukhang/nvim-toggler
require('nvim-toggler').setup {
	inverses = {
		['to'] = 'from',
		['failed'] = 'succeeded',
		['before'] = 'after',
	},
	remove_default_keybinds = true,
}

-- phaazon/mind.nvim
require('mind').setup {
	keymaps = {
		normal = {
			['<cr>'] = 'toggle_node',
			['<Esc>'] = 'toggle_parent',
			['e'] = 'open_data',
			['dd'] = 'delete',
			['<leader>m'] = 'quit',
			['R'] = 'change_icon_menu',
		},
		selection = {
			['<cr>'] = 'toggle_node',
			['e'] = 'open_data',
		}
	}
}

-- s1n7ax/nvim-window-picker (required by mind.nvim)
require('window-picker').setup {
}

-- ofirgall/title.nvim
require('title-nvim').setup {
}

-- johmsalas/text-case.nvim
local textcase = require('textcase')
textcase.setup {
}

api.nvim_create_user_command('UpperCase', function() textcase.current_word('to_upper_case') end, {})
api.nvim_create_user_command('LowerCase', function() textcase.current_word('to_lower_case') end, {})
api.nvim_create_user_command('SnakeCase', function() textcase.current_word('to_snake_case') end, {})
api.nvim_create_user_command('ConstantCase', function() textcase.current_word('to_dash_case') end, {})
api.nvim_create_user_command('DashCase', function() textcase.current_word('to_constant_case') end, {})
api.nvim_create_user_command('DotCase', function() textcase.current_word('to_dot_case') end, {})
api.nvim_create_user_command('CamelCase', function() textcase.current_word('to_camel_case') end, {})
api.nvim_create_user_command('PascalCase', function() textcase.current_word('to_pascal_case') end, {})
api.nvim_create_user_command('TitleCase', function() textcase.current_word('to_title_case') end, {})
api.nvim_create_user_command('PathCase', function() textcase.current_word('to_path_case') end, {})
api.nvim_create_user_command('PhraseCase', function() textcase.current_word('to_phrase_case') end, {})

-- AckslD/nvim-FeMaco.lua
local femaco_margin = {
	width = 10,
	height = 6,
	top = 2
}
require('femaco').setup {
	post_open_float = function(winnr)
		local ns = api.nvim_create_namespace('FeMaco')
		api.nvim_set_hl(ns, 'NormalFloat', { bg = require('ofirkai').scheme.background })
		api.nvim_win_set_hl_ns(winnr, ns)
	end,
	float_opts = function(code_block)
		_ = code_block
		return {
			relative = 'win',
			width = vim.api.nvim_win_get_width(0) - femaco_margin.width,
			height = vim.api.nvim_win_get_height(0) - femaco_margin.height,
			col = femaco_margin.width / 2,
			row = femaco_margin.height / 2 - femaco_margin.top,
			border = 'rounded',
			zindex = 1,
		}
	end,
	ensure_newline = function(base_filetype)
		_ = base_filetype
		return true
	end,
}

-- gbprod/yanky.nvim
require('yanky').setup {
	system_clipboard = {
		sync_with_ring = false,
	},
	highlight = {
		on_put = false,
		on_yank = false,
	},
}

-- ofirgall/open.nvim
require('open').setup {
}

-- ofirgall/open-jira.nvim
require('open-jira').setup {
	url = 'https://volumez.atlassian.net/browse/'
}

-- kylechui/nvim-surround

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
	},
	surrounds = surrounds,
	move_cursor = false,
}

-- zakharykaplan/nvim-retrail
retrail = require('retrail')
retrail.setup {
	hlgroup = 'NvimInternalError',
	filetype = {
		exclude = {
			'diff',
			'git',
			'gitcommit',
			'unite',
			'qf',
			'help',
			'markdown',
			'fugitive',
			'toggleterm',
			'log',
			'noice',
			'nui',
			'notify',
			'floggraph',
			'chatgpt',
		},
	},
	trim = {
		auto = false,
		whitespace = true, -- Trailing whitespace as highlighted.
		blanklines = true, -- Final blank (i.e. whitespace only) lines.
	}
}

api.nvim_create_user_command('TrimWhiteSpace', function() retrail:trim() end, {})

-- Wansmer/treesj
require('treesj').setup {
	use_default_keymaps = false,
}

-- numToStr/Navigator.nvim
require('Navigator').setup {
	disable_on_zoom = false,
}

-- Wansmer/sibling-swap.nvim
require('sibling-swap').setup {
	use_default_keymaps = false,
}

-- trmckay/based.nvim
require('based').setup {
	highlight = 'Title'
}

-- cloudysake/swap-split.nvim
require("swap-split").setup({
	ignore_filetypes = {
		'NvimTree'
	}
})

-- RaafatTurki/hex.nvim
require('hex').setup {
}

-- LeonHeidelbach/trailblazer.nvim
require('trailblazer').setup {
	trail_options = {
		trail_mark_in_text_highlights_enabled = false,
		trail_mark_symbol_line_indicators_enabled = false,
		symbol_line_enabled = false,
	},
	mappings = {
		nv = {
			motions = {
				new_trail_mark = '<M-space>',
				track_back = '<M-b>',
				peek_move_next_down = '<M-n>',
				peek_move_previous_up = '<M-p>',
				toggle_trail_mark_list = '<M-B>',
			},
			actions = {
				delete_all_trail_marks = '<M-L>',
				paste_at_last_trail_mark = '',
				paste_at_all_trail_marks = '',
				set_trail_mark_select_mode = '',
				switch_to_next_trail_mark_stack = '<M-Left>',
				switch_to_previous_trail_mark_stack = '<M-Right>',
				set_trail_mark_stack_sort_mode = '<M-s>',
			},
		},
	}
}

-- aduros/ai.vim
vim.g.ai_no_mappings = true
