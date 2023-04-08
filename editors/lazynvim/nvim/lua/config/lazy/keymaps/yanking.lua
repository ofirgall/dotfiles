local map = require('utils.misc').map

-- Yanking and pasting
map('', '<leader>y', '"+y', 'Start copy to os clipboard E.g: <leader>yy will copy current line to os')
map('', '<leader>Y', '"+y$', 'Copy rest of the line to os clipboard like "Y" but for os clipboard')
map('', '<C-c>', '<cmd>let @+=@"<CR>', 'Copy to os clipboard from default register')
map('n', '<leader>p', '"+p', 'paste from os clipboard')
map('n', '<leader>P', '"+P', 'paste from os clipboard')
map({ 'v' }, '<C-c>', '"+y', 'Copy text in visual')

-- Deleting text without yanking
map('n', '<leader>d', '"_d', 'delete without yanking')
map('n', '<leader>D', '"_D', 'delete without yanking')
map('n', '<leader>c', '"_c', 'change without yanking')
map('n', '<leader>C', '"_C', 'change without yanking')
map('n', '<leader>x', '"_x', 'x without yanking')
map('n', '<leader>X', '"_X', 'x without yanking')
