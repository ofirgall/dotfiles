local M = {}

table.insert(M, {
	-- ChatGPT from nvim
	'jackMort/ChatGPT.nvim',
	cmd = { 'ChatGPT', 'ChatGPTActAs', 'ChatGPTRunCustomCodeAction', 'ChatGPTEditWithInstructions' },
	config = function()
		require('chatgpt').setup {
		}
	end,
	dependencies = {
		'MunifTanjim/nui.nvim',
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope.nvim'
	},
})

table.insert(M, {
	-- Quick ChatGPT from nvim, <C-a> in insert mode or :AI in selection
	'aduros/ai.vim',
	cmd = 'AI',
	init = function()
		vim.g.ai_no_mappings = true
	end,
})

table.insert(M, {
	'dpayne/CodeGPT.nvim',
	cmd = 'Chat',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
	},
})

return M
