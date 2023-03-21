local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	-- bootstrap lazy.nvim
	vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable',
		lazypath, })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require('lazy').setup {
	spec = {
		{ import = 'plugins' },
	},
	defaults = {
		-- TODO: try to make lazy=true
		lazy = false,
		version = false, -- always use the latest git commit
	},
	install = { colorscheme = { 'ofirkai' } },
	checker = { enabled = false }, -- automatically check for plugin updates
	performance = {
		rtp = {
			-- TODO: go over that
			-- disable some rtp plugins
			disabled_plugins = {
				'gzip',
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				'tarPlugin',
				'tohtml',
				'tutor',
				'zipPlugin',
			},
		},
	},
}
