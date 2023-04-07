local api = vim.api

-- lyokha/vim-xkbswitch
vim.cmd([[
let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1
]])

-- aduros/ai.vim
vim.g.ai_no_mappings = true

-- chrisgrieser/nvim-various-textobjs
require('various-textobjs').setup {
	useDefaultKeymaps = true,
}
-- Override "sentence" textobj in favor of subword
local vt = require('various-textobjs')
map({ 'o', 'x' }, 'is', function() vt.subword(true) end)
map({ 'o', 'x' }, 'as', function() vt.subword(false) end)
