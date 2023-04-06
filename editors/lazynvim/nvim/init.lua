NVLOG = vim.env.NVLOG

vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct

require('globals')

local rdir = require('utils.require_dir')
rdir.setup()

rdir.require('config')

-- Lazy load config files
vim.api.nvim_create_autocmd('User', {
	pattern = 'LazyVimStarted',
	callback = function()
		rdir.recursive_require('config/lazy')
	end,
})

require('lazy_config')
