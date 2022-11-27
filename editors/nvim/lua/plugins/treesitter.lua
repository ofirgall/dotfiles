if vim.g.started_by_firenvim then
	do return end
end

-----------------------------------------------------------
-- Tree Sitter
-----------------------------------------------------------

if IS_REMOTE then
	ignore_install_langs = { 'norg', 'foam', 'haskell' }
else
	ignore_install_langs = {}
end

require('nvim-treesitter.configs').setup {
	ensure_installed = 'all',
	sync_install = false,
	ignore_install = ignore_install_langs,
	highlight = {
		enable = true,
		disable = { 'help', 'git_rebase' }
	},
	indent = {
		enable = true
	},
	-- yati = { enable = true },
	textobjects = {
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				[']m'] = '@function.outer',
				[']]'] = '@class.outer',
				[']b'] = '@block.outer',
				[']a'] = '@parameter.inner',
				[']k'] = '@call.outer',
			},
			goto_next_end = {
				[']M'] = '@function.outer',
				[']['] = '@class.outer',
				[']B'] = '@block.outer',
				[']A'] = '@parameter.inner',
				[']K'] = '@call.outer',
			},
			goto_previous_start = {
				['[m'] = '@function.outer',
				['[['] = '@class.outer',
				['[b'] = '@block.outer',
				['[a'] = '@parameter.inner',
				['[k'] = '@call.inner',
			},
			goto_previous_end = {
				['[M'] = '@function.outer',
				['[]'] = '@class.outer',
				['[B'] = '@block.outer',
				['[A'] = '@parameter.inner',
				['[K'] = '@call.inner',
			},
		},
		select = {
			enable = true,
			lookahead = true,
			-- include_surrounding_whitespace = true,
			keymaps = {
				['af'] = '@function.outer',
				['if'] = '@function.inner',
				['ac'] = '@class.outer',
				['ic'] = '@class.inner',
				['ab'] = '@block.outer',
				['ib'] = '@block.inner',
				['aL'] = '@loop.outer', -- `al` is already in used by `a line`
				['iL'] = '@loop.inner', -- same as `al`
				['a/'] = '@comment.outer',
				['i/'] = '@comment.outer', -- no inner for comment
				['aa'] = '@parameter.outer', -- parameter -> argument
				['ia'] = '@parameter.inner',
				['ak'] = '@call.outer',
				['ik'] = '@call.inner',
				['ai'] = '@conditional.outer', -- i as if
				['ii'] = '@conditional.inner',
			},
		},
	},
	-- andymass/vim-matchup
	matchup = {
		enable = true
	}
}
