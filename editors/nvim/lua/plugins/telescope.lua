
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
				width = 0.99,
				preview_width = 0.5,
				height = 0.99
			}
		}
	},
	pickers = {
	},
	extensions = {
	}
}

require('telescope').load_extension('fzf')
