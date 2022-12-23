local api = vim.api

-- ofirgall/ofirkai.nvim
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
		win_options = {
			winblend = 0,
			winhighlight = require('ofirkai.plugins.dressing').winhighlight,
		}
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
	code_action_icon = ''
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
				{ 'filename', shorting_target = 0, icon = '', },
				{
					navic.get_location,
					cond = navic.is_available,
				},
				{
					json_path.get,
					cond = function()
						local ft = api.nvim_buf_get_option(0, 'filetype')
						return ft == 'json' or ft == 'jsonc'
					end,
				}
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
				enabled = false -- I prefer to use cmp-nvim-lsp-signature-help with minimal design
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
		bg = scheme.background,
		fg = scheme.vert_split_fg_active
	},
}

-- echasnovski/mini.animate
require('mini.animate').setup {
	scroll = {
		enable = false
	},
	resize = {
		enable = false,
	},
	open = {
		enable = false,
	},
	close = {
		enable = false
	},
}

-- https://github.com/b0o/incline.nvim/discussions/32
local function get_diagnostic_label(props)
	local icons = { error = '', warn = '', info = '', hint = '', }
	local label = {}

	for severity, icon in pairs(icons) do
		local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
		if n > 0 then
			table.insert(label, { icon .. ' ' .. n .. ' ', group = 'DiagnosticSign' .. severity })
		end
	end
	if #label > 0 then
		table.insert(label, { '| ' })
	end
	return label
end

local function get_git_diff(props)
	local icons = { removed = "", changed = "", added = "" }
	local labels = {}
	local signs = vim.api.nvim_buf_get_var(props.buf, "gitsigns_status_dict")
	-- local signs = vim.b.gitsigns_status_dict
	for name, icon in pairs(icons) do
		if tonumber(signs[name]) and signs[name] > 0 then
			table.insert(labels, { icon .. " " .. signs[name] .. " ",
				group = "Diff" .. name
			})
		end
	end
	if #labels > 0 then
		table.insert(labels, { '| ' })
	end
	return labels
end

-- b0o/incline.nvim
require('incline').setup {
	render = function(props)
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
		local ft_icon, ft_color = require('nvim-web-devicons').get_icon_color(filename)
		local modified = vim.api.nvim_buf_get_option(props.buf, 'modified') and 'bold,italic' or 'bold'

		return {
			-- { get_diagnostic_label(props) },
			{ get_git_diff(props) },
			{ ft_icon, guifg = ft_color }, { ' ' },
			{ filename, gui = modified },
		}
	end,
	window = {
		margin = {
			horizontal = 0,
			vertical = 0,
		},
	},
	hide = {
		focused_win = false,
	},
}
