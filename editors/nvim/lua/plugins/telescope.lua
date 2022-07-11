
require('telescope').setup{
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			},
			n = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			}
		},
		layout_config = {
			horizontal = {
				-- prompt_position = 'top'
				width = 0.90,
				preview_width = 0.5,
				height = 0.90
			},
		},
		prompt_prefix = " ",
	},
	pickers = {
	},
	extensions = {
		['ui-select'] = {
			require('telescope.themes').get_dropdown {
			}
		}
	}
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
