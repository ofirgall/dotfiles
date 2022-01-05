require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
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

require("telescope").load_extension "file_browser"
