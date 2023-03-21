NVLOG = vim.env.NVLOG

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
