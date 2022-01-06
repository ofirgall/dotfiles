require'lualine'.setup {
	options = {
		theme = 'modus-vivendi',
		icons_enabled = true,
		path = 1,
	},
	sections = {
		lualine_b = {'diff', 'diagnostics'},
		-- lualine_c = {require('auto-session-library').current_session_name, 'filename'},
		-- lualine_y = {'hostname', 'progress'},
		lualine_x = {'filetype'},
	}
}

local monokai = require('monokai')
local palette = monokai.classic
palette = palette
highlighted_word_bg = '#343942'
monokai.setup {
    palette = {
		base2 = '#282923',
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
	}
}

require("indent_blankline").setup {
	indent_blankline_use_treesitter = true,
	show_trailing_blankline_indent = false,
}

vim.g.bufferline = {
  icons = 'both',
}
