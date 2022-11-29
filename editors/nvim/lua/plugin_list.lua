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

	-------- LSP --------
	use 'neovim/nvim-lspconfig'

	-- Complete engine --
	use {
		'hrsh7th/nvim-cmp',
		requires = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'dcampos/nvim-snippy',
			'dcampos/cmp-snippy',
			'uga-rosa/cmp-dictionary',
			'petertriho/cmp-git',
			'rcarriga/cmp-dap',
			'f3fora/cmp-spell',
		}
	}

	use 'ofirgall/vim-snippets' -- Default snippets
	use 'glepnir/lspsaga.nvim' -- Sweet ui for rename + code action and hover doc
	use 'RRethy/vim-illuminate' -- Mark word on cursor (ctrl+n/p to move across refs)
	use 'ray-x/lsp_signature.nvim' -- Signature hint while typing
	use 'onsails/lspkind-nvim' -- Adding sweet ui for kind (function/var/method)
	use 'SmiteshP/nvim-navic' -- Shows context in status line (with lsp)
	use 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' -- show diagnostics as virtual lines
	use 'ofirgall/format-on-leave.nvim' -- Format the code when leaving the buffer.
	use 'saecki/crates.nvim' -- "LSP" for `Cargo.toml`
	use 'simrat39/symbols-outline.nvim' -- Tree view for symbols

	-- Language Specific --
	use 'simrat39/rust-tools.nvim' -- Rust tools
	use { 'ray-x/go.nvim', requires = 'ray-x/guihua.lua', run = ':GoUpdateBinaries' } -- Golang tools
	use 'folke/neodev.nvim' -- Adding nvim api signatures and more

	-------- END OF LSP --------

	-- TreeSitter --
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
	use 'nvim-treesitter/playground' -- TreeSitter helper to customize
	-- use { 'yioneko/nvim-yati', requires = 'nvim-treesitter/nvim-treesitter' } -- Better auto-indent atm -- TODO: trying treesitter native indentation
	use 'andymass/vim-matchup' -- Enhance `%` actions

	use 'phelipetls/jsonpath.nvim' -- Added json path winbar component

	-- Textobjects --
	use 'nvim-treesitter/nvim-treesitter-textobjects' -- Textobjects base on treesitter
	use { 'Julian/vim-textobj-variable-segment', requires = 'kana/vim-textobj-user' } -- iv/av: foo_bar_baz = foo, bar, baz text objects
	use { 'D4KU/vim-textobj-chainmember', requires = 'kana/vim-textobj-user' } -- im/am: foo.bar().baz() = foo, bar(), baz()

	-- Telescope --
	use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' } -- Fuzzy finder with alot of integration
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- fzf integration for telescope
	use 'nvim-telescope/telescope-live-grep-args.nvim' -- Better live grep
	use 'nvim-telescope/telescope-ui-select.nvim' -- native nvim ui select with telescope
	use 'axkirillov/easypick.nvim' -- Create telescope from cmd line output, dirty git files for example
	use 'https://code.sitosis.com/rudism/telescope-dict.nvim'

	-- Git --
	use 'lewis6991/gitsigns.nvim' -- Show git diff in the sidebar, hunk actions and more
	use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' } -- Show large diffs :DiffviewOpen
	use 'tpope/vim-fugitive' -- Git cli inside nvim with extra tools :Git, mergetool :Gdiff http://vimcasts.org/episodes/fugitive-vim-resolving-merge-conflicts-with-vimdiff/
	use 'f-person/git-blame.nvim' -- Git blame (status line)
	use {
		'tpope/vim-unimpaired', -- More ][ motions ]n [n for conflicts
		-- event = 'BufRead', -- Lazyload, doesn't work for some reason
	}
	use 'rbong/vim-flog' -- Show git history tree with :Flog (read doc for more)
	use 'rhysd/git-messenger.vim' -- Git blame that allows to explore older commits

	-- Debugging --
	use 'mfussenegger/nvim-dap' -- DAP client for nvim
	use { 'rcarriga/nvim-dap-ui', requires = 'mfussenegger/nvim-dap' } -- UI for debugging
	use 'Weissle/persistent-breakpoints.nvim' -- Keep breakpoints after nvim restart
	use 'ofirgall/goto-breakpoints.nvim' -- Cycle breakpoints with ]d/[d
	use 'andrewferrier/debugprint.nvim' -- make debug prints fast

	-- Startup Time --
	use 'dstein64/vim-startuptime' -- Profile startuptime
	use 'lewis6991/impatient.nvim' -- Faster startuptime

	-- Motion --
	use 'kylechui/nvim-surround' -- Surround text (action)
	-- Leap --
	use {
		'ggandor/leap.nvim', -- Leap around the code (vimium/easymotion jumps)
		requires = { -- plugins
			'ggandor/leap-ast.nvim', -- Use leap.nvim to jump around to treesitter contexts
			'ggandor/flit.nvim', -- Highlight results from f/F/t/T and let you go back forward with the same keys
		}
	}

	-- Operators --
	use 'numToStr/Comment.nvim' -- Comments
	use 'tpope/vim-repeat' -- Extending repeat (.) action
	use 'tommcdo/vim-exchange' -- Exchange texts operator with `cx`
	use 'AndrewRadev/splitjoin.vim' -- split one liner to multi with gS, gJ to join
	use { 'AckslD/nvim-revJ.lua', requires = { 'kana/vim-textobj-user', 'sgur/vim-textobj-parameter' } } -- Reverse join (split)
	use 'monaqa/dial.nvim' -- Enhance C-X/A

	-- Navigation --
	use { 'ThePrimeagen/harpoon', requires = 'nvim-lua/plenary.nvim' } -- Mark frequent files and get to there quickly

	-- Design & UI --
	use { 'ofirgall/ofirkai.nvim', branch = 'exp' } -- my colorscheme
	use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' } -- Status line
	use 'lukas-reineke/indent-blankline.nvim' -- Indent line helper
	use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' } -- Tabline
	use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons', } -- File Tree
	use 'stevearc/dressing.nvim' -- Add ui for default vim.ui.input
	use 'nvim-treesitter/nvim-treesitter-context' -- Add code context to top of the line
	use { 'folke/noice.nvim', -- Nice ui for notify, :messages, and better cmdline
		requires = {
			'MunifTanjim/nui.nvim',
			'rcarriga/nvim-notify',
			'hrsh7th/nvim-cmp',
		}
	}
	use 'nvim-zh/colorful-winsep.nvim' -- Highlight current window seperator
	use 'petertriho/nvim-scrollbar' -- Scroll bar

	-- Openers --
	use 'ofirgall/open.nvim'
	use 'ofirgall/open-jira.nvim'

	-- Misc --
	use { 'nagy135/typebreak.nvim', requires = 'nvim-lua/plenary.nvim' } -- Type practice from nvim
	use 'gbprod/yanky.nvim' -- Improve yank experience
	use 'lambdalisue/suda.vim' -- Sudo write/read (SudaWrite/Read)
	use 'windwp/nvim-autopairs' -- Closes (--' etc.
	use 'ofirgall/nvim-retrail' -- Whitespace trailing
	use 'ofirgall/AutoSave.nvim' -- Auto save
	use 'tiagovla/scope.nvim' -- Scopes buffers for tabpages
	use 'famiu/bufdelete.nvim' -- delete buffers ctrl+q
	use 'rmagatti/auto-session' -- Session Manager
	use 'ethanholz/nvim-lastplace' -- Save last place
	use 'mg979/vim-visual-multi' -- Multi cursors
	use 'mizlan/iswap.nvim' -- Swap arguments, elements (:ISwap)
	use 'ofirgall/Navigator.nvim' -- Navigate in panes integrated in vim and tmux
	use 'lyokha/vim-xkbswitch' -- Switch to english for normal mode
	use { 'michaelb/sniprun', run = 'bash ./install.sh' } -- Run snippets in your code
	use 'nacro90/numb.nvim' -- Peek at line number before jump
	use { 'danymat/neogen', requires = 'nvim-treesitter/nvim-treesitter' } -- Doc generator
	use 'jbyuki/venn.nvim' -- Draw ascii boxes and arrows, start the mode with :Draw, exit with escape, HJKL for arrows, f for box (inside <C-v>)
	use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end } -- NVIM in firefox
	use 'ojroques/vim-oscyank' -- Yank from remote
	use 'mbbill/undotree' -- visualize undo/redo tree (F5)
	use 'gennaro-tedesco/nvim-peekup' -- visualize copy registers
	use 'akinsho/toggleterm.nvim' -- Terminal toggle for nvim <C-t>
	use 'NMAC427/guess-indent.nvim' -- Adjust tabs/spaces settings
	use 'shivamashtikar/tmuxjump.vim' -- jump to files that printed in another tmux panes
	use 'szw/vim-maximizer' -- Maximize windows (splits) in vim
	use { 'nvim-neorg/neorg', requires = 'nvim-lua/plenary.nvim' } -- .norg plugin better orgmode
	use { 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim' } -- review todo in the quickfix list with :Todo..
	use 'hkupty/iron.nvim' -- lua/python interactive shell (repl) inside nvim
	use 'norcalli/nvim-colorizer.lua' -- colorize hexcolor values in buffer
	use { 'anuvyklack/hydra.nvim', requires = 'anuvyklack/keymap-layer.nvim' }
	use 'ziontee113/color-picker.nvim' -- color picker
	use 'rbong/vim-buffest' -- edit macros and registers
	use 'nguyenvukhang/nvim-toggler' -- Invert words like true<->false, on<->off with <leader>i
	use 'ofirgall/title.nvim' -- Title generator
	use 'johmsalas/text-case.nvim' -- Smart substitute
	use 'micarmst/vim-spellsync' -- Rebuild sync files when needed
	use 'AckslD/nvim-FeMaco.lua' -- edit code blocks in markdown
	use {
		'phaazon/mind.nvim', -- notetaking with tree
		tag = "v2.*",
		requires = { 's1n7ax/nvim-window-picker', tag = 'v1.*' }
	}
	use { 'toppair/peek.nvim', run = 'deno task --quiet build:fast' }
	use 'mtdl9/vim-log-highlighting' -- Highlight .log files
	use 'romainl/vim-cool' -- Disables search highlighting when you are done searching
	use 'chrisgrieser/nvim-genghis'

	-- Improvement Games
	use 'ThePrimeagen/vim-be-good'

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)
