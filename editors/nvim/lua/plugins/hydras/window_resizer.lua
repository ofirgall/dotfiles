HYDRAS['window_resizer'] = {
	hint = [[
 ^^^^    Size
 ^^^^-------------
 _+_ _-_: height
 _>_ _<_: width
 ^ _=_ ^: equalize
 ^  _<Esc>_
	]],
	config = {
		timeout = 4000,
		hint = {
			border = 'rounded'
		},
	},
	mode = 'n',
	body = '<C-w>',
	heads = {
		-- Size
		{ '+', '<C-w>+' },
		{ '-', '<C-w>-' },
		{ '>', '2<C-w>>', { desc = 'increase width' } },
		{ '<', '2<C-w><', { desc = 'decrease width' } },
		{ '=', '<C-w>=', { exit = true, desc = 'equalize' } },
		--
		{ '<Esc>', nil, { exit = true } },
	},
}

return {}
