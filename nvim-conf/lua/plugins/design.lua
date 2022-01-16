local gps = require("nvim-gps")
require'lualine'.setup {
	options = {
		theme = 'modus-vivendi',
		icons_enabled = true,
		path = 1,
	},
	sections = {
		lualine_b = {'diff', 'diagnostics'},
		lualine_c = {'filename', { gps.get_location, cond = gps.is_available }},
		lualine_x = {},
		lualine_y = {'require"lsp-status".status()'},
		lualine_z = {'filetype'},
	}
}

local monokai = require('monokai')
local palette = monokai.classic
palette = palette
highlighted_word_bg = '#343942'
monokai.setup {
    palette = {
		base2 = '#23241e',
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
			fg = '#e878d2',
			style = 'italic',
		},
		TSAttribute = {
			fg = palette.pink,
			style = 'none',
		},
		TSConstant = {
			fg = '#e878d2',
			style = 'none',
		},
		TSComment = {
			fg = palette.base6,
			style = 'none',
		},
		-- For yaml fields, changes field of python and cpp too :(
		-- TSField = {
		-- 	fg = palette.pink,
		-- 	style = 'none',
		-- },
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
			bg = palette.base3,
			fg = palette.yellow,
		},
		CursorLine = {
			bg = palette.base3,
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
			bg = '#1322ad',
		},
	}
}

require("indent_blankline").setup {
	indent_blankline_use_treesitter = true,
	show_trailing_blankline_indent = false,
}

vim.g.bufferline = {
  icons = 'both',
}
