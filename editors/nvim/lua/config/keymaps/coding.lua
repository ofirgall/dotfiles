local map = require('utils.map').map

-- Add text
local add_new_line = 'i\\n<Esc>'
map('n', '<leader>n', add_new_line, 'Add newline')
map('n', '&', 'i&<Esc>', 'Add ampersand')
map('i', '<C-k>', '<C-O>o', 'Insert new line in insert mode')

-- Move through wrapped lines
map({ 'n', 'x' }, 'j',
	function()
		return vim.v.count > 0 and 'j' or 'gj'
	end,
	'Move down inside wrapped line', { silent = true, expr = true })

map({ 'n', 'x' }, 'k',
	function()
		return vim.v.count > 0 and 'k' or 'gk'
	end,
	'Move up inside wrapped line', { silent = true, expr = true })

map('n', '<C-o>', '<C-o>zz', 'Recenter after C-o')
map('n', '<C-i>', '<C-i>zz', 'Recenter after C-i')

-- Rename without LSP
map('n', '<leader><F2>', '*:%s///g<left><left>', 'Rename current word with <leader>F2')
map('x', '<F2>', '"hy:%s/<C-r>h//g<left><left>', 'Rename visual')

map('n', ']g', function() require('utils.lsp').goto_next_diag() end, 'Next problem')
map('n', '[g', function() require('utils.lsp').goto_prev_diag() end, 'Prev problem')

-- requires nvim-treesitter/nvim-treesitter-textobjects
map('i', '<M-]>', '<C-O>]a', 'Jump to next argument in insert mode', { silent = true, remap = true })
map('i', '<M-[>', '<C-O>[a', 'Jump to prev argument in insert mode', { silent = true, remap = true })
