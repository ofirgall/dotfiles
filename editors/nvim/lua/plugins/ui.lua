-- ofirgall/ofirkay.nvim
require('ofirkai').setup {
}

-- lukas-reineke/indent-blankline.nvim
require('indent_blankline').setup {
	use_treesitter = true,
	show_trailing_blankline_indent = false,
	space_char_blankline = ' ',
}
vim.opt.list = true
vim.opt.listchars:append('space:⋅')

-- stevearc/dressing.nvim
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

-- nvim-treesitter/nvim-treesitter-context
require('treesitter-context').setup {
}

-- kyazdani42/nvim-tree.lua
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

if not vim.g.started_by_firenvim then
	y_section = {}

	-- f-person/git-blame.nvim
	if vim.fn.has('wsl') == 1 then -- don't use git blame in wsl because of performance
		vim.g.gitblame_enabled = 0
	else
		local git_blame = require('gitblame')
		table.insert(y_section, { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available })
		vim.g.gitblame_display_virtual_text = 0
		vim.g.gitblame_message_template = '<author> • <date>'
		vim.g.gitblame_date_format = '%d/%m/%Y'
	end

	-- SmiteshP/nvim-navic
	local navic = require('nvim-navic')

	-- nvim-lualine/lualine.nvim
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
				{ navic.get_location, cond = navic.is_available },
			},
			lualine_x = { { get_current_lsp_server_name, icon = ' LSP:' } },
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
end
