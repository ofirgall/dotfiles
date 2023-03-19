NVLOG = vim.env.NVLOG

local rdir = require('utils.require_dir')
rdir.setup()

rdir.require('config')
require('lazy_config')

-- Lazy load config files
vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyVimStarted',
    callback = function()
        rdir.require('config/lazy')
    end,
})
