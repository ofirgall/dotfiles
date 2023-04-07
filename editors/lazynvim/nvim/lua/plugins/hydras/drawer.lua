local M = {}

HYDRAS['draw'] = {
	name = 'Draw',
	hint = [[
^^^^    Draw
^^^^-------------
Arrows: _<C-h>_ _<C-j>_ _<C-k>_ _<C-l>_
Box (select box with visual block first): _<C-f>_
^ ^				_<Esc>_: exit
]],
	config = {
		color = 'pink',
		invoke_on_body = true,
		hint = {
			position = 'bottom',
			border = 'rounded'
		},
		on_enter = function()
			vim.o.virtualedit = 'all'
		end,
	},
	mode = { 'n' },
	heads = {
		{ '<C-h>', '<C-v>h:VBox<CR>' },
		{ '<C-j>', '<C-v>j:VBox<CR>' },
		{ '<C-k>', '<C-v>k:VBox<CR>' },
		{ '<C-l>', '<C-v>l:VBox<CR>' },
		{ '<C-f>', ':VBox<CR>', { mode = 'v' } },
		{ '<Esc>', nil, { exit = true, nowait = true } },
	},
	cmd = 'Draw'
}

table.insert(M, {
	'jbyuki/venn.nvim',
	cmd = 'VBox'
})

return M
