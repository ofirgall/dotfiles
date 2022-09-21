local api = vim.api

require('ofirkai').setup {
}

vim.opt.list = true
vim.opt.listchars:append('space:⋅')
require('indent_blankline').setup {
	use_treesitter = true,
	show_trailing_blankline_indent = false,
	space_char_blankline = ' ',
}

require('dressing').setup {
	input = {
		insert_only = false,
		start_in_insert = false,

		max_width = { 140, 0.9 },
		min_width = { 60, 0.2 },

		winblend = 0,

		mappings = {
			n = {
				['q'] = 'Close',
				['<Esc>'] = 'Close',
				['<CR>'] = 'Confirm',
				['<C-p>'] = 'HistoryPrev',
				['<C-n>'] = 'HistoryNext',
			},
			i = {
				['<M-q>'] = 'Close',
				['<C-c>'] = 'Close',
				['<CR>'] = 'Confirm',
				['<Up>'] = 'HistoryPrev',
				['<Down>'] = 'HistoryNext',
				['<C-p>'] = 'HistoryPrev',
				['<C-n>'] = 'HistoryNext',
			},
		}
	},
}

require('treesitter-context').setup {
}

require 'nvim-tree'.setup {
	view = {
		adaptive_size = true,
		mappings = {
			list = {
				{ key = '<Escape>', action = 'close_node' },
				{ key = 'f', action = 'find in path', action_cb = find_in_path },
				{ key = 'gh', action = 'git history in path', action_cb = git_hist_path },
				{ key = '<C-o>', action = 'split' },
			}
		}
	},
	renderer = {
		symlink_destination = false
	}
}
vim.api.nvim_create_user_command('Locate', ':NvimTreeFindFile', {})

vim.g.gitblame_display_virtual_text = 0
vim.g.gitblame_message_template = '<author> • <date>'
vim.g.gitblame_date_format = '%d/%m/%Y'

if not vim.g.started_by_firenvim then
	local lsp_gps = require('nvim-navic')

	y_section = {}
	if vim.fn.has('wsl') == 1 then -- don't use git blame in wsl because of performance
		vim.g.gitblame_enabled = 0
	else
		local git_blame = require('gitblame')
		table.insert(y_section, { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available })
	end

	require 'lualine'.setup {
		options = {
			theme = require('ofirkai.statuslines.lualine').theme,
			icons_enabled = true,
			path = 1,
			always_divide_middle = false,
		},
		sections = {
			lualine_b = { 'branch', 'diff', 'diagnostics' },
			lualine_c = {
				{ 'filename', shorting_target = 0 },
				{ lsp_gps.get_location, cond = lsp_gps.is_available },
			},
			lualine_x = { get_current_lsp_server_name, icon = ' LSP:' },
			lualine_y = y_section,
			lualine_z = { 'filetype' },
		},
	}
	vim.opt.laststatus = 3

	-- bufferline.nvim, must be loaded after color scheme
	require('bufferline').setup {
		options = {
			separator_style = 'slant',
			offsets = { { filetype = 'NvimTree', text = 'File Explorer', text_align = 'center' } },
			show_buffer_icons = true,
			themable = true,
			numbers = 'ordinal',
			max_name_length = 40,
		},
		highlights = require('ofirkai.tablines.bufferline').highlights
	}

	-- WSL 1 is too slow for that
	if vim.fn.has('wsl') == 0 then
		local tint_ft_ignore = {
			'toggleterm',
			'NvimTree',
			'DiffviewFiles',
		}
		require('tint').setup({
			tint = -45,
			saturation = 0.6,
			highlight_ignore_patterns = { 'WinSeparator', 'Status.*', 'IndentBlankline', 'EndOfBuffer' },
			window_ignore_function = function(winid)
				local bufid = api.nvim_win_get_buf(winid)
				local buf_ft = api.nvim_buf_get_option(bufid, 'filetype')

				for _, ft in ipairs(tint_ft_ignore) do
					if buf_ft == ft then
						return true
					end
				end

				local floating = api.nvim_win_get_config(winid).relative ~= ''
				local diff = api.nvim_get_option_value('diff', { buf = bufid })

				if floating or diff then
					return false
				end

				return floating
			end
		})
	end
end
