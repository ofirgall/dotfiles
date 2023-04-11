local map = require('utils.misc').map

-- Tabline binds
map('n', '<C-q>', function() require('bufdelete').bufdelete(0, true) end, 'Close current tab')
map('n', '<leader>1', function() require('bufferline').go_to_buffer(1, true) end, 'Go to tab #1')
map('n', '<leader>2', function() require('bufferline').go_to_buffer(2, true) end, 'Go to tab #2')
map('n', '<leader>3', function() require('bufferline').go_to_buffer(3, true) end, 'Go to tab #3')
map('n', '<leader>4', function() require('bufferline').go_to_buffer(4, true) end, 'Go to tab #4')
map('n', '<leader>5', function() require('bufferline').go_to_buffer(5, true) end, 'Go to tab #5')
map('n', '<leader>6', function() require('bufferline').go_to_buffer(6, true) end, 'Go to tab #6')
map('n', '<leader>7', function() require('bufferline').go_to_buffer(7, true) end, 'Go to tab #7')
map('n', '<leader>8', function() require('bufferline').go_to_buffer(8, true) end, 'Go to tab #8')
map('n', '<leader>9', function() require('bufferline').go_to_buffer(9, true) end, 'Go to tab #9')
map('n', '<leader>0', function() require('bufferline').go_to_buffer(10, true) end, 'Go to tab #10')
map('n', '<leader><Tab>', '<cmd>b#<cr>', 'Go to last active tab')

map('n', '<C-,>', '<cmd>BufferLineCyclePrev<CR>', 'Move to left')
map('n', '<C-.>', '<cmd>BufferLineCycleNext<CR>', 'Move to right')
map('n', '<C-<>', '<cmd>BufferLineMovePrev<CR>', 'Move + grab to with you to left')
map('n', '<C->>', '<cmd>BufferLineMoveNext<CR>', 'Move + grab to with you to right')

-- Vim tabs
map('n', 'g1', '<cmd>tabnext1<cr>', 'Go to tabpage #1')
map('n', 'g2', '<cmd>tabnext2<cr>', 'Go to tabpage #2')
map('n', 'g3', '<cmd>tabnext3<cr>', 'Go to tabpage #3')
map('n', 'g4', '<cmd>tabnext4<cr>', 'Go to tabpage #4')
map('n', 'g5', '<cmd>tabnext5<cr>', 'Go to tabpage #5')
map('n', 'g6', '<cmd>tabnext6<cr>', 'Go to tabpage #6')
map('n', 'g7', '<cmd>tabnext7<cr>', 'Go to tabpage #7')
map('n', 'g8', '<cmd>tabnext8<cr>', 'Go to tabpage #8')
map('n', 'g9', '<cmd>tabnext9<cr>', 'Go to tabpage #9')
map('n', 'g0', '<cmd>tabnext10<cr>', 'Go to tabpage #10')
map('n', 'gq', '<cmd>tabclose<cr>', 'Close tabpage')
map('n', '<M-t>', '<cmd>tabnew %<cr>', 'New tabpage')

map({ 'n', 'v' }, '<leader>,', '<cmd>tabprev<cr>', 'Previous tabpage with Alt+, (<). NOT FILE TABS')
map({ 'n', 'v' }, '<leader>.', '<cmd>tabnext<cr>', 'Next tabpage with Alt+. (>). NOT FILE TABS')
map('i', '<M-,>', '<C-O><cmd>tabprev<cr>', 'Previous tabpage with Alt+, (<). NOT FILE TABS')
map('i', '<M-.>', '<C-O><cmd>tabnext<cr>', 'Next tabpage with Alt+. (>). NOT FILE TABS')
