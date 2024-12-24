------------------------------
-- This file is the entry point of a neovim configuration
--
-- In order to load the config with KoalaVim we load:
--     1. KoalaVim config - keymaps, options, usercmds, autocmds
--     2. User config - keymaps, options, usercmds, autocmds (Overrides KoalaVim config)
--     3. lazy.nvim - Loads the plugins
------------------------------

------------------------------
-- Remap space as leader key to set the keymaps with correct leader key
------------------------------

local leader_key = ' '

------------------------------
-- Load KoalaVim config
------------------------------
require('koala_init').load_koala(leader_key)

------------------------------
-- Load user config
------------------------------
local require_dir = require('KoalaVim.utils.require_dir')
require_dir.recursive_require('config')

-- Lazy load config/lazy after KoalaVim
vim.api.nvim_create_autocmd('User', {
	pattern = 'KoalaVimStarted',
	callback = function()
		require_dir.recursive_require('config_lazy')
	end,
})

------------------------------
-- Load lazy.nvim
------------------------------
require('koala_init').load_lazy({
	-- lazy.nvim user spec (combined with KoalaVim spec)
	user_spec = {
		{ import = 'plugins' },
	},
	-- lazy.nvim user opts (overrides KoalaVim lazy.nvim opts)
	lazy_opts = {
		install = {
			colorscheme = { 'ofirkai' }, -- Which colorscheme to let lazy.nvim load first
		},
	},
})
