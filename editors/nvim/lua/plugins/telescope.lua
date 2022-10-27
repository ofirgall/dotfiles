if vim.g.started_by_firenvim then
	do return end
end

require('telescope').setup {
	defaults = {
		dynamic_preview_title = true,
		mappings = {
			i = {
				['<C-j>'] = 'move_selection_next',
				['<C-k>'] = 'move_selection_previous',
				['<C-n>'] = 'cycle_history_next',
				['<C-p>'] = 'cycle_history_prev',
			},
			n = {
				['<C-j>'] = 'move_selection_next',
				['<C-k>'] = 'move_selection_previous',
				['<C-o>'] = 'select_horizontal',
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
		prompt_prefix = ' ',
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
require('telescope').load_extension('harpoon')
