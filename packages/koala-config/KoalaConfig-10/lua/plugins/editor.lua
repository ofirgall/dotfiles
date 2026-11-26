local M = {}

-- TODO: make it dev
table.insert(M, {
	'ofirgall/title.nvim',
	cmd = 'Title',
	config = function()
		require('title-nvim').setup({})
	end,
})

table.insert(M, {
	'subnut/nvim-ghost.nvim',
	init = function()
		vim.g.nvim_ghost_autostart = 0
	end,
})

table.insert(M, {
	'hrsh7th/nvim-cmp',
	opts = {
		lsp_max_item_count = 30,
	}
})

return M
