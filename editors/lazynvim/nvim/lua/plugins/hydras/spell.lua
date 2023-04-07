-- Spell fixing quickly
local spell_status_before = false

HYDRAS['spell fixer'] = {
	hint = [[
 _j_: Next _k_: Prev
 _<Enter>_: Suggest Fix

  _<Esc>_ quit _q_ quit
	]],
	config = {
		color = 'pink',
		timeout = 10000,
		invoke_on_body = true,
		hint = {
			border = 'rounded'
		},
		on_enter = function()
			spell_status_before = vim.opt.spell
			vim.opt.spell = true
		end,
		on_exit = function()
			vim.opt.spell = spell_status_before
		end,
	},
	mode = 'n',
	body = '<C-s>',
	heads = {
		{ 'j', function()
			vim.api.nvim_input(']s')
			require('utils.misc').center_screen()
		end, },
		{ 'k', function()
			vim.api.nvim_input('[s')
			require('utils.misc').center_screen()
		end, },
		{ '<Enter>', '<cmd>telescope spell_suggest<CR>' },
		--
		{ '<Esc>', nil, { exit = true, nowait = true } },
		{ 'q', nil, { exit = true, nowait = true } },
	},
}

return {}
