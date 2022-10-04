if vim.g.started_by_firenvim then
	do return end
end

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
