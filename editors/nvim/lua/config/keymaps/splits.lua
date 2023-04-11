local map = require('utils.map').map

-- Splits
map('n', '<leader>qa', function() require('utils.splits').close_all_but_current() end, 'Close all buffers but current')
map('n', '<leader>qA', '<cmd>wqa!<cr>', 'Write all + close vim')

map('n', '<M-e>', function() require('utils.splits').smart_split('vertical') end, 'Vsplit')
map('n', '<M-o>', function() require('utils.splits').smart_split('horizontal') end, 'split')

map('n', '<M-q>', function() require('utils.splits').close() end, 'Close split')
map('n', '<M-w>', function() require('utils.splits').close() end, 'Close split')
map('t', '<M-q>', '<cmd>bd!<CR>', 'Close terminal')

-- Duplicate your view into split (MAX 2)
map('n', 'gV', function() require('utils.splits').split_if_not_exist(true) end, 'Vertical split if not exist')
map('n', 'gX', function() require('utils.splits').split_if_not_exist(false) end, 'Horziontal split if not exist')
