
require('gitsigns').setup{
}

require('Comment').setup{
}

require('nvim-autopairs').setup{
    check_ts = true,
	enable_moveright = false,
}

require('autosave').setup{
	clean_command_line_interval = 1000
}

require'nvim-lastplace'.setup{
}

vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
]])
