if vim.g.started_by_firenvim then
	do return end
end

local layout = 'horizontal'
local cycle_layout_list = { 'vertical', 'horizontal' }
if NVLOG then
	layout = 'vertical'
	cycle_layout_list = { 'horizontal', 'vertical' }
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
				['<C-h>'] = require('telescope.actions.layout').cycle_layout_prev,
				['<C-l>'] = require('telescope.actions.layout').cycle_layout_next,
				['<CR>'] = require('telescope.actions').select_default + require('telescope.actions').center,
				['<C-x>'] = require('telescope.actions').select_horizontal + require('telescope.actions').center,
				['<C-v>'] = require('telescope.actions').select_vertical + require('telescope.actions').center,
				['<C-t>'] = require('telescope.actions').select_tab + require('telescope.actions').center,
				['<C-s>'] = require('telescope.actions.layout').toggle_preview,
			},
			n = {
				['<C-j>'] = 'move_selection_next',
				['<C-k>'] = 'move_selection_previous',
				['<C-h>'] = require('telescope.actions.layout').cycle_layout_prev,
				['<C-l>'] = require('telescope.actions.layout').cycle_layout_next,
				['<C-o>'] = 'select_horizontal',
				['<CR>'] = require('telescope.actions').select_default + require('telescope.actions').center,
				['<C-x>'] = require('telescope.actions').select_horizontal + require('telescope.actions').center,
				['<C-v>'] = require('telescope.actions').select_vertical + require('telescope.actions').center,
				['<C-t>'] = require('telescope.actions').select_tab + require('telescope.actions').center,
				['<C-s>'] = require('telescope.actions.layout').toggle_preview,
			},
		},
		layout_config = {
			horizontal = {
				width = 0.90,
				preview_width = 0.5,
				height = 0.90,
			},
			vertical = {
				width = 0.95,
				preview_height = 0.75,
				height = 0.90,
			},
		},
		prompt_prefix = ' ',
		layout_strategy = layout,
		cycle_layout_list = cycle_layout_list,
	},
	pickers = {
	},
	extensions = {
		['ui-select'] = {
			require('telescope.themes').get_dropdown {
			},
		},
		undo = {
			side_by_side = true,
			layout_strategy = 'vertical',
			layout_config = {
				preview_height = 0.5,
			},
			mappings = {
				n = {
					['<cr>'] = require('telescope-undo.actions').yank_additions,
					['<S-cr>'] = require('telescope-undo.actions').yank_deletions,
					['<C-cr>'] = require('telescope-undo.actions').restore,
				},
				i = {
					['<cr>'] = require('telescope-undo.actions').yank_additions,
					['<S-cr>'] = require('telescope-undo.actions').yank_deletions,
					['<C-cr>'] = require('telescope-undo.actions').restore,
				},
			},
		},
	},
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')
require('telescope').load_extension('harpoon')
require('telescope').load_extension('undo')
