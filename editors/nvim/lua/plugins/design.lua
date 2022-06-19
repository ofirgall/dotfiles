
local monokai = require('monokai')
local palette = monokai.classic

vim.g.gitblame_display_virtual_text = 0
vim.g.gitblame_message_template = '<author> • <date>'
vim.g.gitblame_date_format = '%d/%m/%Y'

if not vim.g.started_by_firenvim then
	local gps = require("nvim-gps")
	local lsp_gps = require("nvim-navic")
	local git_blame = require("gitblame")

	-- customized modus-vivendi
	local colors = {
		black      = '#000000',
		white      = palette.white,
		red        = '#ffa0a0',
		green      = '#88cf88',
		blue       = '#92baff',
		magenta    = '#feacd0',
		cyan       = '#a0bfdf',
		brown      = '#33332a',
		lightbrown = '#404036',
		darkgray   = '#202020',
		lightgray  = '#434343',
		orange     = '#de933c'
	}

	local lualine_theme = {
		normal = {
			a = { bg = colors.orange, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.lightbrown, fg = colors.orange },
			c = { bg = colors.brown, fg = colors.white },
			x = { bg = colors.brown, fg = colors.orange },
		},
		insert = {
			a = { bg = colors.cyan, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.lightbrown, fg = colors.cyan },
			c = { bg = colors.brown, fg = colors.white },
			x = { bg = colors.brown, fg = colors.cyan },
		},
		visual = {
			a = { bg = colors.magenta, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.lightbrown, fg = colors.magenta },
			c = { bg = colors.brown, fg = colors.white },
			x = { bg = colors.lightbrown, fg = colors.magenta },
		},
		replace = {
			a = { bg = colors.red, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.lightbrown, fg = colors.red },
			c = { bg = colors.brown, fg = colors.white },
			x = { bg = colors.lightbrown, fg = colors.red },
		},
		command = {
			a = { bg = colors.green, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.lightbrown, fg = colors.green },
			c = { bg = colors.brown, fg = colors.white },
			x = { bg = colors.lightbrown, fg = colors.green },
		},
		inactive = {
			a = { bg = colors.darkgray, fg = colors.lightgray, gui = 'bold' },
			b = { bg = colors.darkgray, fg = colors.lightgray },
			c = { bg = colors.darkgray, fg = colors.lightgray },
			x = { bg = colors.darkgray, fg = colors.lightgray },
		},
	}

	local lsp_server_component = {
		function()
			local msg = '———'
			local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
			local clients = vim.lsp.get_active_clients()
			if next(clients) == nil then
				return msg
			end
			for _, client in ipairs(clients) do
				local filetypes = client.config.filetypes
				if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
					return client.name
				end
			end
			return msg
		end,
		icon = ' LSP:',
	}

	local is_treesitter_gps_available = function ()
		return not lsp_gps.is_available() and gps.is_available()
	end

	require'lualine'.setup {
		options = {
			theme = lualine_theme,
			icons_enabled = true,
			path = 1,
			always_divide_middle = false,
		},
		sections = {
			lualine_b = {'diff', 'diagnostics'},
			lualine_c = {'filename', {lsp_gps.get_location, cond = lsp_gps.is_available }, { gps.get_location, cond = is_treesitter_gps_available }},
			lualine_x = {lsp_server_component},
			lualine_y = {{git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available}},
			lualine_z = {'filetype'},
		},
	}

	-- barbar
	vim.g.bufferline = {
		icons = 'both',
		closable = false,
		clickable = false,
	}

	-- Load lualine late (buggy if not)
	late_lualine_setup_id = vim.api.nvim_create_autocmd({'BufEnter', 'InsertEnter'}, {
		pattern = '*',
		callback = function()
			require('lualine').setup()
			vim.opt.laststatus = 3
			vim.api.nvim_del_autocmd(late_lualine_setup_id)
		end
	})
else
	-- barbar
	vim.g.bufferline = {
		auto_hide = true,
	}
end

local highlighted_word_bg = '#343942'
local background = '#22221c'
local const_pink = '#e878d2'
local tree_bg = '#181816'
local tab_visible_fg = '#b3ab60'
local cursor_line_bg = '#2e2e27'
monokai.setup {
	palette = {
		base2 = background,
		base0 = background,
		-- base3 = '#272a33',
		base3 = '#1d2026',
		brown = '#d1ca86',
	},
	custom_hlgroups = {
		TSFunction = {
			fg = palette.aqua,
			style = 'none',
		},
		TSKeywordFunction = {
			fg = palette.green,
			style = 'italic',
		},
		TSParameter = {
			fg = palette.orange,
			style = 'italic',
		},
		TSMethod = {
			fg = palette.aqua,
			style = 'none',
		},
		TSConstructor = {
			fg = palette.aqua,
			style = 'none',
		},
		TSType = {
			fg = palette.green,
			style = 'italic',
		},
		TSConstMacro = {
			fg = palette.pink,
			style = 'none',
		},
		TSFuncMacro = {
			fg = const_pink,
			style = 'italic',
		},
		TSAttribute = {
			fg = palette.pink,
			style = 'none',
		},
		TSConstant = {
			fg = const_pink,
			style = 'none',
		},
		TSComment = {
			fg = palette.base6,
			style = 'none',
		},
		Whitespace = { -- Indent lines
			fg = palette.base4,
			style = 'none',
		},
		TSCall = {
			fg = palette.pink,
			style = 'none',
		},
		LineNr = {
			bg = '#282923',
			fg = palette.orange,
		},
		CursorLineNr = {
			bg = cursor_line_bg,
			fg = palette.yellow,
		},
		CursorLine = {
			bg = cursor_line_bg
		},
		TSLabel = {
			fg = palette.white,
			style = 'italic',
		},
		LspReferenceText = {
			bg = highlighted_word_bg,
			style = 'underline',
		},
		LspReferenceRead = {
			bg = highlighted_word_bg,
			style = 'underline',
		},
		LspReferenceWrite = {
			bg = highlighted_word_bg,
			style = 'underline',
		},
		VertSplit = {
			fg = '#948f5a'
		},
		SpellBad = {
			ctermfg = palette.red,
			style = 'undercurl'
		},
		SpellCap = {
			ctermfg = palette.purple,
			style = 'undercurl',
		},
		SpellRare = {
			ctermfg = palette.aqua,
			style = 'undercurl',
		},
		SpellLocal = {
			ctermfg = palette.pink,
			style = 'undercurl',
		},
		------- PLUGINS -------
		-- Multi Cursor Design
		TabLineSel = {
			fg = '#78b6e8',
			bg = highlighted_word_bg,
		},
		Tabline = {
			fg = '#f20aee',
			bg = highlighted_word_bg,
			-- style = 'reverse',
		},
		Search = {
			bg = '#790f91',
		},
		Visual = {
			bg = '#555449',
		},
		TelescopeSelection = {
			fg = palette.white,
			bg = palette.base3,
			style = 'none'
		},
		-- nvim-tree
		NvimTreeNormal = {
			bg = tree_bg
		},
		NvimTreeWindowPicker = {
			fg = palette.pink,
			bg = palette.base3,
			style = 'bold'
		},
		-- Complete menu
		Pmenu = {
			fg = palette.white,
			bg = '#2c2c26',
		},
		PmenuSel = {
			fg = palette.white,
			bg = '#40403a',
		},
		PmenuSelBold = {
			fg = palette.white,
			bg = '#40403a',
		},
		PmenuThumb = {
			fg = palette.purple,
			bg = '#47473b',
		},
		-- hrsh7th/nvim-cmp
		CmpItemAbbrMatch = {
			-- fg = '#fc97e8',
			fg = '#34d8f7',
		},
		CmpItemAbbrMatchFuzzy = {
			fg = '#34d8f7',
		},
		-- romgrk/barbar.nvim
		BufferCurrent = {
			fg = palette.white
		},
		BufferVisible = {
			fg = tab_visible_fg,
			bg = tree_bg
		},
		BufferVisibleIndex = {
			fg = tab_visible_fg,
			bg = tree_bg
		},
		BufferVisibleMod = {
			fg = tab_visible_fg,
			bg = tree_bg
		},
		BufferVisibleSign = {
			fg = tab_visible_fg,
			bg = tree_bg
		},
		BufferVisibleTarget = {
			fg = tab_visible_fg,
			bg = tree_bg
		},
		BufferInActive = {
			fg = palette.grey,
			bg = tree_bg
		},
		BufferInactiveIndex = {
			fg = palette.grey,
			bg = tree_bg
		},
		BufferInactiveMod = {
			fg = palette.grey,
			bg = tree_bg
		},
		BufferInactiveSign = {
			fg = palette.grey,
			bg = tree_bg
		},
		BufferInactiveTarget = {
			fg = palette.grey,
			bg = tree_bg
		},
		BufferOffset = {
			bg = tree_bg
		},
		BufferTabpageFill = {
			bg = tree_bg
		},
	}
}

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
require("indent_blankline").setup {
	use_treesitter = true,
	show_trailing_blankline_indent = false,
	space_char_blankline = " ",
}
