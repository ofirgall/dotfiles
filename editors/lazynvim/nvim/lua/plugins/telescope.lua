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
		hidden = true,
		follow = true,
		default_text = telescope_default_text(mode),
		layout_strategy = 'horizontal'
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
	opts = {
		defaults = {
			dynamic_preview_title = true,
			mappings = {
				i = {
					['<C-j>'] = 'move_selection_next',
					['<C-k>'] = 'move_selection_previous',
					['<C-n>'] = 'cycle_history_next',
					['<C-p>'] = 'cycle_history_prev',
					['<C-h>'] = function() require('telescope.actions.layout').cycle_layout_prev() end,
					['<C-l>'] = function() require('telescope.actions.layout').cycle_layout_next() end,
					['<C-s>'] = function() require('telescope.actions.layout').toggle_preview() end,
				},
				n = {
					['<C-j>'] = 'move_selection_next',
					['<C-k>'] = 'move_selection_previous',
					['<C-h>'] = function() require('telescope.actions.layout').cycle_layout_prev() end,
					['<C-l>'] = function() require('telescope.actions.layout').cycle_layout_next() end,
					['<C-o>'] = 'select_horizontal',
					['<C-s>'] = function() require('telescope.actions.layout').toggle_preview() end,
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
				},
				mappings = {
					n = {
						['<cr>'] = function() require('telescope-undo.actions').yank_additions() end,
						['<S-cr>'] = function() require('telescope-undo.actions').yank_deletions() end,
						['<C-cr>'] = function() require('telescope-undo.actions').restore() end,
					},
					i = {
						['<cr>'] = function() require('telescope-undo.actions').yank_additions() end,
						['<S-cr>'] = function() require('telescope-undo.actions').yank_deletions() end,
						['<C-cr>'] = function() require('telescope-undo.actions').restore() end,
					},
				},
			},
		},
	},
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
		{ mode = 'v', '<leader>fw', '<Esc><cmd>lua live_grep({}, "v")<cr>', desc = 'search in all files (default text is from visual)' },
		{ '<leader>fcw', function() live_grep({}, 'cword') end, desc = 'Find current word' },
		{ '<leader>fcW', function() live_grep({}, 'cWORD') end, desc = 'Find current word' },
		{ '<leader>fm', ':set opfunc=LiveGrepRawOperator<CR>g@', desc = 'Find with movement' },
		-- Find in current dir
		{ '<leader>fcd', live_grep_current_dir, desc = 'Find in current dir' },
		{ '<leader>fcdw', function() live_grep_current_dir(vim.fn.expand('<cword>')) end,
			desc = 'Find in current dir current word' },
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
			vim.cmd('Telescope undo') -- TODO: convert to lua api
		end, {})
	end,
})

return M
