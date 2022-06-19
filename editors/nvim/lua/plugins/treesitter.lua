-----------------------------------------------------------
-- Tree Sitter
-----------------------------------------------------------

if IS_REMOTE then
	ignore_install_langs = { "norg", "foam", "haskell"}
else
	ignore_install_langs = {}
end

require'nvim-treesitter.configs'.setup {
	ensure_installed = "all",
	sync_install = false,
	ignore_install = ignore_install_langs,
	highlight = {
		enable = true,
		disable = {},
		additional_vim_regex_highlighting = false,
		custom_captures = {
		}
	},
	yati = { enable = true },
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["gj"] = "@function.outer",
				["]]"] = "@class.outer",
				["]b"] = "@block.outer",
				["]a"] = "@parameter.inner",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["gJ"] = "@function.outer",
				["]["] = "@class.outer",
				["]B"] = "@block.outer",
				["]A"] = "@parameter.inner",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["gk"] = "@function.outer",
				["[["] = "@class.outer",
				["[b"] = "@block.outer",
				["[a"] = "@parameter.inner",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["gK"] = "@function.outer",
				["[]"] = "@class.outer",
				["[B"] = "@block.outer",
				["[A"] = "@parameter.inner",
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
