-----------------------------------------------------------
-- Tree Sitter
-----------------------------------------------------------

-- https://github.com/

require'nvim-treesitter.configs'.setup {
	ensure_installed = "all",
	sync_install = false,
	ignore_install = { "norg" },
	highlight = {
		enable = true,
		disable = {},
		additional_vim_regex_highlighting = false,
		custom_captures = {
		}
	},
	yati = { enable = true },
	-- TODO: different file, smart loop for bindings
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["gj"] = "@function.outer",
				["]]"] = "@class.outer",
				["]b"] = "@block.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["gJ"] = "@function.outer",
				["]["] = "@class.outer",
				["]B"] = "@block.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["gk"] = "@function.outer",
				["[["] = "@class.outer",
				["[b"] = "@block.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["gK"] = "@function.outer",
				["[]"] = "@class.outer",
				["[B"] = "@block.outer",
			},
		},
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["ab"] = "@block.outer",
				["ib"] = "@block.inner",
				["al"] = "@loop.outer",
				["il"] = "@loop.inner",
				["a/"] = "@comment.outer",
				["i/"] = "@comment.outer", -- no inner for comment
				["aa"] = "@parameter.outer", -- parameter -> argument
				["ia"] = "@parameter.inner",
			},
		},
	},
}

require("nvim-gps").setup()
require('spellsitter').setup()
