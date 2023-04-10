local map = require('utils.misc').map

map('n', '<F8>', function() require('utils.misc').restart_nvim() end, 'Restart nvim')

-- Scroll with arrows
map('', '<Down>', '<C-e>', 'Down to scroll')
map('', '<Up>', '<C-y>', 'Up to scroll')

-- Toggle spell check
map('n', '<F1>', ':set spell!<cr>', 'Toggle spell check')
map('i', '<F1>', '<C-O>:set spell!<cr>', 'Toggle spell check')

map('n', '<M-r>', '<cmd>echo "Current File Reloaded!"<cr><cmd>luafile %<cr>', 'Reload current luafile')

map('t', '<Esc>', '<C-\\><C-n>', 'Escape from terminal with escape key')

map('n', '<leader>b', function() require('utils.misc').deploy() end, 'Build & deploy')
map('n', '<leader>B', function()
	require('utils.misc').reset_deploy()
	require('utils.misc').deploy()
end, 'Reset deploy, build & deploy')
