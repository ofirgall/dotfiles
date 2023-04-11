-- TODO: lazy load this functions

local api = vim.api

local function get_range(mode)
	local start_pos = { 0, 0 }
	local end_pos = { 0, 0 }
	if mode == 'v' then
		start_pos = api.nvim_buf_get_mark(0, '<')
		end_pos = api.nvim_buf_get_mark(0, '>')
	elseif mode == 'n' then
		start_pos = api.nvim_buf_get_mark(0, '[')
		end_pos = api.nvim_buf_get_mark(0, ']')
	end

	return start_pos, end_pos
end

local function get_current_line_text(mode)
	local current_line = api.nvim_get_current_line()
	local start_pos, end_pos = get_range(mode)

	return string.sub(current_line, start_pos[2] + 1, end_pos[2] + 1)
end

local function telescope_default_text(mode)
	if mode == nil then
		return ''
	elseif mode == 'cword' then
		return vim.fn.expand('<cword>')
	elseif mode == 'cWORD' then
		return vim.fn.expand('<cWORD>')
	else
		return get_current_line_text(mode)
	end
end

local function find_current_file()
	local current_file = vim.fn.expand('%:t:r')
	require('telescope.builtin').find_files({
		default_text = current_file,
		hidden = true,
		follow = true,
	})
end

local function find_files(mode, cwd)
	require('telescope.builtin').find_files({
		cwd = cwd,
		default_text = telescope_default_text(mode),
	})
end

local function live_grep(opts, mode)
	opts = opts or {}
	opts.prompt_title = 'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob]")'
	if not opts.default_text then
		opts.default_text = '-F "' .. telescope_default_text(mode)
	end

	require('telescope').extensions.live_grep_args.live_grep_args(opts)
end

local function live_grep_current_dir(default_text)
	default_text = default_text or ''
	live_grep({
		default_text = '-g"' .. vim.fn.fnamemodify(vim.fn.expand('%'), ':.:h') .. '/*"' .. ' -F "' .. default_text })
end


vim.cmd("function! LiveGrepRawOperator(...) \n lua live_grep({}, 'n') \n endfunction") -- used by `<leader>fm`

--------------------------------------------------------------------
-- LSP

local function goto_def()
	local ft = api.nvim_buf_get_option(0, 'filetype')
	if ft == 'man' then
		api.nvim_command(':Man ' .. vim.fn.expand('<cWORD>'))
	elseif ft == 'help' then
		api.nvim_command(':help ' .. vim.fn.expand('<cword>'))
	else
		require 'telescope.builtin'.lsp_definitions({
			show_line = false,
		})
	end
end

local function lsp_references()
	require('telescope.builtin').lsp_references({
		include_declaration = false,
		show_line = false,
	})
end


local function lsp_implementations()
	require('telescope.builtin').lsp_implementations {
		show_line = false,
	}
end

local split_if_not_exist = require('utils.splits').split_if_not_exist

---------------------------------------------------------------------

local M = {}

local layout = 'horizontal'
local cycle_layout_list = { 'vertical', 'horizontal' }
if NVLOG then
	layout = 'vertical'
	cycle_layout_list = { 'horizontal', 'vertical' }
end
table.insert(M, {
	'nvim-telescope/telescope.nvim',
	cmd = 'Telescope',
	version = false,
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope-fzf-native.nvim',
		'nvim-telescope/telescope-ui-select.nvim',
	},
	config = function()
		require('telescope').setup {
			defaults = {
				dynamic_preview_title = true,
				mappings = {
					i = {
						['<C-j>'] = 'move_selection_next',
						['<C-k>'] = 'move_selection_previous',
						['<C-n>'] = 'cycle_history_next',
						['<C-p>'] = 'cycle_history_prev',
						['<C-h>'] = require('telescope.actions.layout').cycle_layout_prev,
						['<C-l>'] = require('telescope.actions.layout').cycle_layout_next,
						['<CR>'] = require('telescope.actions').select_default + require('telescope.actions').center,
						['<C-x>'] = require('telescope.actions').select_horizontal + require('telescope.actions').center,
						['<C-v>'] = require('telescope.actions').select_vertical + require('telescope.actions').center,
						['<C-t>'] = require('telescope.actions').select_tab + require('telescope.actions').center,
						['<C-s>'] = require('telescope.actions.layout').toggle_preview,
					},
					n = {
						['<C-j>'] = 'move_selection_next',
						['<C-k>'] = 'move_selection_previous',
						['<C-h>'] = require('telescope.actions.layout').cycle_layout_prev,
						['<C-l>'] = require('telescope.actions.layout').cycle_layout_next,
						['<C-o>'] = 'select_horizontal',
						['<CR>'] = require('telescope.actions').select_default + require('telescope.actions').center,
						['<C-x>'] = require('telescope.actions').select_horizontal + require('telescope.actions').center,
						['<C-v>'] = require('telescope.actions').select_vertical + require('telescope.actions').center,
						['<C-t>'] = require('telescope.actions').select_tab + require('telescope.actions').center,
						['<C-s>'] = require('telescope.actions.layout').toggle_preview,
					},
				},
				layout_config = {
					horizontal = {
						width = 0.90,
						preview_width = 0.5,
						height = 0.90,
					},
					vertical = {
						width = 0.95,
						preview_height = 0.75,
						height = 0.90,
					},
				},
				prompt_prefix = ' ',
				layout_strategy = layout,
				cycle_layout_list = cycle_layout_list,
			},
			extensions = {
				['ui-select'] = {
					-- require('telescope.themes').get_dropdown {
					-- },
				},
				undo = {
					side_by_side = true,
					layout_strategy = 'vertical',
					layout_config = {
						preview_height = 0.5,
						preview_cutoff = 30,
					},
					mappings = {
						n = {
							['<cr>'] = require('telescope-undo.actions').yank_additions,
							['<S-cr>'] = require('telescope-undo.actions').yank_deletions,
							['<C-cr>'] = require('telescope-undo.actions').restore,
						},
						i = {
							['<cr>'] = require('telescope-undo.actions').yank_additions,
							['<S-cr>'] = require('telescope-undo.actions').yank_deletions,
							['<C-cr>'] = require('telescope-undo.actions').restore,
						},
					},
				},
			},
			pickers = {
				find_files = {
					hidden = true,
					follow = true,
					layout_strategy = 'horizontal'
				},
			},
		}
	end,
	keys = {
		-- General telescope utils
		{
			'<leader>fr',
			function() require('telescope.builtin').resume({ initial_mode = 'normal' }) end,
			desc = 'Find resume'
		},
		-- Find files
		{ '<leader>ff', find_files, desc = 'Find file' },
		{ mode = 'v', '<leader>ff', '<Esc><cmd>lua find_files("v")<cr>', desc = 'find file, text from visual' },
		{ '<leader>fcf', function() find_files('cword') end, desc = 'Find files with current word' },
		{ '<leader>T', find_current_file, desc = 'find files with the current file (use to find _test fast)' },
		-- Find buffer
		{ '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'Browse open buffers' },

		----- LSP Bindings -----

		-- Goto definition
		{ 'gd', goto_def, desc = 'Go to Definition' },
		{
			'<MiddleMouse>',
			function()
				vim.api.nvim_input('<LeftMouse>')
				vim.api.nvim_input('<cmd>vsplit<cr>')
				goto_def()
			end,
			desc = 'Go to Definition in split'
		},
		{
			'<C-LeftMouse>',
			function()
				vim.api.nvim_input('<LeftMouse>')
				goto_def()
			end,
			desc = 'Go to Definition'
		},
		{
			'gvd',
			function()
				split_if_not_exist(true)
				goto_def()
			end,
			desc = 'Go to Definition in Vsplit'
		},
		{
			'gxd',
			function()
				split_if_not_exist(false)
				goto_def()
			end,
			desc = 'Go to Definition in Xsplit'
		},

		-- Goto references
		{ 'gr', lsp_references, desc = 'Go to References' },
		{
			'gvr',
			function()
				split_if_not_exist(true)
				lsp_references()
			end,
			desc = 'Go to References in Vsplit'
		},
		{
			'gxr',
			function()
				split_if_not_exist(false)
				lsp_references()
			end,
			desc = 'Go to References in Xsplit'
		},

		-- Goto implementations
		{ 'gi', lsp_implementations, desc = 'Go to Implementation' },
		{
			'gvi',
			function()
				split_if_not_exist(true)
				lsp_implementations()
			end,
			desc = 'Go to Implementation in Vsplit'
		},
		{
			'gxi',
			function()
				split_if_not_exist(false)
				lsp_implementations()
			end,
			desc = 'Go to Implementation in Xsplit',
		},

		-- Goto type
		{
			'gt',
			function() require 'telescope.builtin'.lsp_type_definitions() end,
			desc = 'Go to Type',
		},
		{
			'gvt',
			function()
				split_if_not_exist(true)
				require 'telescope.builtin'.lsp_type_definitions {}
			end,
			desc = 'Go to Type in Vsplit'
		},
		{
			'gxt',
			function()
				split_if_not_exist(false)
				require 'telescope.builtin'.lsp_type_definitions {}
			end,
			desc = 'Go to Type in Xsplit'
		},

		-- Goto symbol
		{
			'gs',
			function()
				require 'telescope.builtin'.lsp_document_symbols({
					symbol_width = 65,
					symbol_type_width = 8,
					fname_width = 0,
					layout_config = {
						height = 15,
						width = 65 + 8 + 8,
					},
					layout_strategy = 'cursor',
					sorting_strategy = 'ascending', -- From top
					preview = { hide_on_startup = true },
				})
			end,
			desc = 'Go Symbols'
		},
		{
			'gS',
			function() require 'telescope.builtin'.lsp_dynamic_workspace_symbols() end,
			'Go workspace Symbols',
		},

		-- Go to problem
		{
			'gp',
			function() require 'telescope.builtin'.diagnostics { bufnr = 0 } end,
			desc = 'Go to Problems'
		},
		{
			'gP',
			function() require 'telescope.builtin'.diagnostics() end,
			desc = 'Go to workspace Problems',
		},

	},
})

table.insert(M, {
	-- fzf integration for telescope
	'nvim-telescope/telescope-fzf-native.nvim',
	lazy = true,
	build = 'make',
	config = function()
		require('telescope').load_extension('fzf')
	end,
})

table.insert(M, {
	-- native nvim ui select with telescope
	'nvim-telescope/telescope-ui-select.nvim',
	lazy = true,
	config = function()
		require('telescope').load_extension('ui-select')
	end,
})

table.insert(M, {
	-- Better live grep
	'nvim-telescope/telescope-live-grep-args.nvim',
	keys = {
		-- Find word
		{ '<leader>fw', live_grep, desc = 'search in all files (fuzzy finder)' },
		{
			mode = 'v',
			'<leader>fw',
			'<Esc><cmd>lua live_grep({}, "v")<cr>',
			desc = 'search in all files (default text is from visual)'
		},
		{ '<leader>fcw', function() live_grep({}, 'cword') end, desc = 'Find current word' },
		{ '<leader>fcW', function() live_grep({}, 'cWORD') end, desc = 'Find current word' },
		{ '<leader>fm', ':set opfunc=LiveGrepRawOperator<CR>g@', desc = 'Find with movement' },
		-- Find in current dir
		{ '<leader>fcd', live_grep_current_dir, desc = 'Find in current dir' },
		{
			'<leader>fcdw',
			function() live_grep_current_dir(vim.fn.expand('<cword>')) end,
			desc = 'Find in current dir current word'
		},
	},
	dependencies = 'nvim-telescope/telescope.nvim',
})

table.insert(M, {
	-- Dictionary with telescope
	'https://code.sitosis.com/rudism/telescope-dict.nvim',
	dependencies = 'nvim-telescope/telescope.nvim',
	keys = {
		{
			'ss',
			function()
				require('telescope.builtin').spell_suggest({
					prompt_title = '',
					layout_config = {
						height = 0.25,
						width = 0.25,
					},
					layout_strategy = 'cursor',
					sorting_strategy = 'ascending', -- From top
				})
			end,
			desc = 'Spell suggest'
		},
		{
			'sy',
			function()
				require('telescope').extensions.dict.synonyms({
					prompt_title = '',
					layout_config = {
						height = 0.4,
						width = 0.60,
					},
					layout_strategy = 'cursor',
					sorting_strategy = 'ascending', -- From top
				})
			end,
			desc = 'Synonyms'
		},
	},
})

table.insert(M, {
	-- Undotree
	'debugloop/telescope-undo.nvim',
	dependencies = 'nvim-telescope/telescope.nvim',
	cmd = 'UndoTree',
	config = function()
		require('telescope').load_extension('undo')
		vim.api.nvim_create_user_command('UndoTree', function()
			require('telescope').extensions.undo.undo()
		end, {})
	end,
})

table.insert(M, {
	'axkirillov/easypick.nvim',
	dependencies = {
		'nvim-telescope/telescope.nvim',
	},
	keys = {
		{ '<leader>gD', '<cmd>Easypick dirtyfiles<CR>', desc = 'Git dirtyfiles' },
	},
	config = function()
		local easypick = require('easypick')
		easypick.setup {
			pickers = {
				{
					name = 'dirtyfiles',
					command = 'git status -s | cut -c 4-',
					previewer = easypick.previewers.default(),
				},
			},
		}
	end,
})

return M
