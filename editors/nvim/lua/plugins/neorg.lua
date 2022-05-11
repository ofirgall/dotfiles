
require('neorg').setup {
	load = {
		["core.defaults"] = {},
		["core.norg.concealer"] = {},
		["core.norg.completion"] = {
			config = {
				engine = 'nvim-cmp'
			}
		},
	}
}
