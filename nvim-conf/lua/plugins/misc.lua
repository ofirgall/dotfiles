
require('gitsigns').setup{
}

require('Comment').setup{
}

require('nvim-autopairs').setup{
    check_ts = true,
	-- enable_moveright = false,
}

require('autosave').setup{
	clean_command_line_interval = 1000
}

require'nvim-lastplace'.setup{
}

require'sniprun'.setup{
	display = {
		"Classic"
	}
}

require("revj").setup{
	new_line_before_last_bracket = false,
	add_seperator_for_last_parameter = false,
	enable_default_keymaps = true,
}

require('numb').setup{
}

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
require'nvim-tree'.setup {
	view = {
		mappings = {
			list = {
				{ key = "<Escape>", cb = tree_cb("close_node") },
			}
		}
	}
}

vim.cmd([[
command! Locate execute 'NvimTreeFindFile'
]])

vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
]])
