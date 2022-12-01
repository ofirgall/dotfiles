local api = vim.api

-- ofirgall/ofirkay.nvim
local scheme = require('ofirkai.design').scheme
require('ofirkai').setup {
}

-- lukas-reineke/indent-blankline.nvim
require('indent_blankline').setup {
	use_treesitter = true,
	show_trailing_blankline_indent = false,
	space_char_blankline = ' ',
	show_current_context = true,
	show_current_context_start = false,
	context_highlight_list = { 'InlayHints' },
}
vim.opt.list = true
vim.opt.listchars:append('lead:⋅')

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
		},
		winhighlight = require('ofirkai.plugins.dressing').winhighlight
	},
}

-- nvim-treesitter/nvim-treesitter-context
require('treesitter-context').setup {
}

-- kyazdani42/nvim-tree.lua
require('nvim-tree').setup {
	view = {
		adaptive_size = true,
		mappings = {
			list = {
				{ key = '<Escape>', action = 'close_node' },
				{ key = 'f', action = 'find in path', action_cb = find_in_path },
				{ key = 'gh', action = 'git history in path', action_cb = git_hist_path },
				{ key = '<C-o>', action = 'split' },
			}
		},
		relativenumber = true,
		number = false,
		signcolumn = 'no'
	},
	renderer = {
		symlink_destination = false
	}
}
vim.api.nvim_create_user_command('Locate', ':NvimTreeFindFile', {})

-- glepnir/lspsaga.nvim
vim.diagnostic.config {
	signs = {
		priority = 8
	}
}
require('lspsaga').init_lsp_saga({
	code_action_keys = {
		quit = '<Escape>',
		exec = '<CR>',
	},
	code_action_lightbulb = {
		sign_priority    = 10,
		sign             = true,
		virtual_text     = false,
		enable_in_insert = false
	},
	rename_in_select = false,
	symbol_in_winbar = {
		enable = false
	},
})

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
	navic.setup {
		separator = "  "
	}

	local ofirkai_lualine = require('ofirkai.statuslines.lualine')
	local json_path = require('jsonpath')
	local winbar = {
		lualine_a = {},
		lualine_b = {
			{
				'filename',
				file_status = false,
				icon = '',
				color = ofirkai_lualine.winbar_color,
				padding = { left = 4 }
			},
		},
		lualine_c = {
			{
				navic.get_location,
				icon = "",
				cond = navic.is_available,
				color = ofirkai_lualine.winbar_color,
			},
			{
				json_path.get,
				icon = "",
				cond = function()
					local ft = api.nvim_buf_get_option(0, 'filetype')
					return ft == 'json' or ft == 'jsonc'
				end,
				color = ofirkai_lualine.winbar_color,
			}
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {}
	}

	-- nvim-lualine/lualine.nvim
	require('lualine').setup {
		options = {
			theme = ofirkai_lualine.theme,
			icons_enabled = true,
			path = 1,
			always_divide_middle = false,
			disabled_filetypes = {
				winbar = { 'gitcommit', 'NvimTree', 'toggleterm', 'fugitive', 'floggraph', 'git', 'gitrebase', 'quickfix' },
			},
			globalstatus = true,
		},
		sections = {
			lualine_b = { { 'branch', icon = '' }, 'diff', 'diagnostics' },
			lualine_c = {
				{ 'filename', shorting_target = 0 },
			},
			lualine_x = {
				{
					function() return ' RECORDING ' .. vim.fn.reg_recording() end,
					cond = function() return vim.fn.reg_recording() ~= '' end,
					separator = '|',
				},
				{
					'searchcount',
					separator = '|',
					icon = '',
				},
				{ get_current_lsp_server_name, icon = ' LSP:' }
			},
			lualine_y = y_section,
			lualine_z = { { 'filetype', separator = '' }, 'progress' },
		},
		winbar = winbar,
		inactive_winbar = winbar,
	}

	-- Refresh lualine for recording macros
	api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
		group = config_autocmds,
		callback = require('lualine').refresh
	})

	-- akinsho/bufferline.nvim must be loaded after color scheme
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

	-- rcarriga/nvim-notify
	require('notify').setup {
		background_colour = scheme.ui_bg,
		fps = 60,
		stages = "slide",
		timeout = 1000,
		max_width = 50,
		max_height = 20,
	}

	-- folke/noice.nvim
	require('noice').setup {
		popupmenu = {
			enabled = false,
		},
		lsp = {
			signature = {
				enabled = false -- I prefer to use ray-x/lsp_signature.nvim with minimal design
			},
			override = {
				-- Override `vim.lsp.buf.hover` and `nvim-cmp` doc formatter with `noice` doc formatter.
				['vim.lsp.util.convert_input_to_markdown_lines'] = true,
				['vim.lsp.util.stylize_markdown'] = true,
				['cmp.entry.get_documentation'] = true,
			},
		},
		routes = require('misc.noice_routes'),
	}
end

-- andymass/vim-matchup
-- Disable matchup higlights, use the default of vim
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = "*",
	callback = function()
		vim.b.matchup_matchparen_enabled = 0
	end
})

-- nvim-zh/colorful-winsep.nvim
require('colorful-winsep').setup {
	highlight = {
		guibg = scheme.background,
		guifg = scheme.vert_split_fg_active
	},
}

-- petertriho/nvim-scrollbar
require('scrollbar').setup {
	marks = {
		GitAdd = {
			text = "│",
			priority = 7,
			color = nil,
			cterm = nil,
			highlight = "GitSignsAdd",
		},
		GitChange = {
			text = "│",
			priority = 7,
			color = nil,
			cterm = nil,
			highlight = "GitSignsChange",
		},
		GitDelete = {
			text = "_",
			priority = 7,
			color = nil,
			cterm = nil,
			highlight = "GitSignsDelete",
		},
	},
	handlers = {
		diagnostic = true,
		search = false, -- I don't like the dependence plugin
		gitsigns = true,
	},
}
require('scrollbar.handlers.gitsigns').setup {
}
