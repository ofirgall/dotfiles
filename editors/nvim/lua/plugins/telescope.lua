local fb_actions = require "telescope".extensions.file_browser.actions

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-e>"] = fb_actions.create,
      },
	  n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-e>"] = fb_actions.create,
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

require("telescope").load_extension('file_browser')
require('telescope').load_extension('fzf')
