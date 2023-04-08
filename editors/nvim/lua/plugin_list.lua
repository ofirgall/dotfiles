-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- https://github.com/wbthomason/packer.nvim

-- Recommended Plugins: https://github.com/rockerBOO/awesome-neovim

local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()


return require('packer').startup(function()
	use 'wbthomason/packer.nvim' -- packer can manage itself

	-- Textobjects --
	use { 'D4KU/vim-textobj-chainmember', requires = 'kana/vim-textobj-user' } -- im/am: foo.bar().baz() = foo, bar(), baz()

	use {
		'tpope/vim-unimpaired', -- More ][ motions ]n [n for conflicts
		-- event = 'BufRead', -- Lazyload, doesn't work for some reason
	}

	-- Operators --
	use 'tommcdo/vim-exchange' -- Exchange texts operator with `cx`

	-- Misc --
	use 'lambdalisue/suda.vim' -- Sudo write/read (SudaWrite/Read)

	use 'famiu/bufdelete.nvim' -- delete buffers ctrl+q

	use 'mizlan/iswap.nvim' -- Swap arguments, elements (:ISwap)

	use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end } -- NVIM in firefox

	use 'rbong/vim-buffest' -- edit macros and registers

	use 'ofirgall/vim-log-highlighting' -- Highlight .log files

	use 'chrisgrieser/nvim-genghis'

	-- AI
	use {
		'dpayne/CodeGPT.nvim', -- Make ChatGPT interact with the code
		requires = {
			'nvim-lua/plenary.nvim',
			'MunifTanjim/nui.nvim',
		},
	}

	-- Improvement Games
	use 'ThePrimeagen/vim-be-good'

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)
