local M = {}

local api = vim.api

local scheme = require('ofirkai.design').scheme

-- TODO: to LSP treesitter module
-- nvim-treesitter/nvim-treesitter-context
require('treesitter-context').setup {
}

if not NVLOG then
	-- TODO: to LSP module
	-- glepnir/lspsaga.nvim
	vim.diagnostic.config {
		signs = {
			priority = 8,
		},
	}
	require('lspsaga').setup({
		code_action = {
			keys = {
				quit = '<Escape>',
				exec = '<CR>',
			},
		},
		lightbulb = {
			sign_priority = 10,
			sign = true,
			virtual_text = false,
			enable_in_insert = false,
		},
		rename = {
			in_select = false,
			whole_project = false,
		},
		symbol_in_winbar = {
			enable = false,
		},
		ui = {
			code_action = '',
			colors = {
				normal_bg = scheme.ui_bg,
				title_bg = scheme.mid_orange,
			},
		},
	})
end

return M
