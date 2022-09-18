-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- https://github.com/wbthomason/packer.nvim

-- Recommended Plugins: https://github.com/rockerBOO/awesome-neovim

local cmd = vim.cmd
cmd [[packadd packer.nvim]]

-- Configure 'lyokha/vim-xkbswitch' before loading
vim.g.XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
vim.g.XkbSwitchEnabled = 1
vim.g.XkbSwitchSkipGhKeys = { 'gh', 'gH' }

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
			'f3fora/cmp-spell',
			'petertriho/cmp-git',
			'rcarriga/cmp-dap',
		}
	}

	use 'ofirgall/vim-snippets' -- Default snippets
	use 'glepnir/lspsaga.nvim' -- Sweet ui for rename + code action and hover doc
	use 'RRethy/vim-illuminate' -- Mark word on cursor (ctrl+n/p to move across refs)
	use 'ray-x/lsp_signature.nvim' -- Signature hint while typing
	use 'onsails/lspkind-nvim' -- Adding sweet ui for kind (function/var/method)
	use 'j-hui/fidget.nvim' -- Lsp Status in the bottom right corner
	use 'Mofiqul/trld.nvim' -- Show diagnostics in the top right corner
	use 'SmiteshP/nvim-navic' -- same as nvim-gps but using LSP instead (more accurate)
	use 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' -- show diagnostics as virtual lines
	use 'lukas-reineke/lsp-format.nvim' -- Auto format on save
	use 'folke/lua-dev.nvim' -- Adding nvim api signatures and more
	use { 'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu' } -- Advanced code action menu

	-------- END OF LSP --------

	-- TreeSitter --
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
	use 'nvim-treesitter/playground' -- TreeSitter helper to customize
	use { 'SmiteshP/nvim-gps', requires = 'nvim-treesitter/nvim-treesitter' } -- Shows context in status line (with treesitter)
	use { 'yioneko/nvim-yati', requires = 'nvim-treesitter/nvim-treesitter' } -- Better auto-indent atm

	use 'numToStr/Comment.nvim' -- Comments
	use 'nvim-treesitter/nvim-treesitter-textobjects' -- Movements base on treesitter
	use 'lewis6991/spellsitter.nvim' -- Enable spellchecking with treesitter

	-- Telescope --
	use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' } -- Fuzzy finder with alot of integration
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- fzf integration for telescope
	use 'nvim-telescope/telescope-live-grep-args.nvim' -- Better live grep
	use 'nvim-telescope/telescope-ui-select.nvim' -- native nvim ui select with telescope
	use 'axkirillov/easypick.nvim' -- Create telescope from cmd line output, dirty git files for example

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

	-- Startup Time --
	use 'dstein64/vim-startuptime' -- Profile startuptime
	use 'lewis6991/impatient.nvim' -- Faster startuptime
	use 'nathom/filetype.nvim' -- faster filetype detection

	-- Motion --
	use 'tpope/vim-repeat' -- Extending repeat (.) action
	use 'machakann/vim-sandwich' -- Sandwich text (<leader>sa action)
	-- Leap --
	use {
		'ggandor/leap.nvim', -- Leap around the code (vimium/easymotion jumps)
		requires = { -- plugins
			'ggandor/leap-ast.nvim', -- Use leap.nvim to jump around to treesitter contexts
			'ggandor/flit.nvim', -- Highlight results from f/F/t/T and let you go back forward with the same keys
		}
	}

	-- Design & UI --
	use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' } -- Status line
	use 'levouh/tint.nvim' -- Tint inactive splits
	use 'lukas-reineke/indent-blankline.nvim' -- Indent line helper
	use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' } -- Tabline
	use 'tanvirtin/monokai.nvim' -- Color theme (customized)
	use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons', } -- File Tree
	use 'gen740/SmoothCursor.nvim' -- track cursor movment in columns markers
	use 'stevearc/dressing.nvim' -- Add ui for default vim.ui.input
	use 'nvim-treesitter/nvim-treesitter-context' -- Add code context to top of the line

	-- Misc --
	use 'lambdalisue/suda.vim' -- Sudo write/read (SudaWrite/Read)
	use 'windwp/nvim-autopairs' -- Closes (--' etc.
	use 'ellisonleao/glow.nvim' -- Markdown preview
	use 'ntpeters/vim-better-whitespace' -- Whitespace trailing
	use 'ofirgall/AutoSave.nvim' -- Auto save
	use 'tiagovla/scope.nvim' -- Scopes buffers for tabpages
	use 'famiu/bufdelete.nvim' -- delete buffers ctrl+q
	use { 'xolox/vim-session', requires = 'xolox/vim-misc' } -- Session Manager
	use 'ethanholz/nvim-lastplace' -- Save last place
	use 'mg979/vim-visual-multi' -- Multi cursors
	use 'mizlan/iswap.nvim' -- Swap arguments, elements (:ISwap)
	use 'christoomey/vim-tmux-navigator' -- Navigate in panes integrated in vim and tmux
	use 'lyokha/vim-xkbswitch' -- Switch to english for normal mode
	use { 'michaelb/sniprun', run = 'bash ./install.sh' } -- Run snippets in your code
	use { 'AckslD/nvim-revJ.lua', requires = { 'kana/vim-textobj-user', 'sgur/vim-textobj-parameter' } } -- Reverse join (split)
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
	use 'rust-lang/rust.vim' -- Rust utils (RustFmt on save)
	use { 'ThePrimeagen/refactoring.nvim', requires = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' } } -- Refactor tool
	use { 'nvim-neorg/neorg', requires = 'nvim-lua/plenary.nvim' } -- .norg plugin better orgmode
	use { 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim' } -- review todo in the quickfix list with :Todo..
	-- use 'hkupty/iron.nvim' -- lua/python interactive shell (repl) inside nvim
	use 'norcalli/nvim-colorizer.lua' -- colorize hexcolor values in buffer
	use 'hrsh7th/nvim-pasta' -- Auto indent on paste, cycle on yank history after paste with <C-n>/<C-p>
	use { 'anuvyklack/hydra.nvim', requires = 'anuvyklack/keymap-layer.nvim' }
	use 'ziontee113/color-picker.nvim' -- color picker
	use { 'ray-x/go.nvim', requires = 'ray-x/guihua.lua', run = ':GoUpdateBinaries' } -- Golang tools
	use 'rbong/vim-buffest' -- edit macros and registers
	use 'tmux-plugins/vim-tmux-focus-events' -- FocusGained/FocusLost events
	use 'andrewferrier/debugprint.nvim' -- make debug prints fast
	use 'nguyenvukhang/nvim-toggler' -- Invert words like true<->false, on<->off with <leader>i
	use {
		'phaazon/mind.nvim', -- notetaking with tree
		tag = "v2.*",
		requires = { 's1n7ax/nvim-window-picker', tag = 'v1.*' }
	}
	use {
		'iamcco/markdown-preview.nvim', -- Markdown preview
		run = function() vim.fn['mkdp#util#install']() end,
		ft = { 'markdown' }
	}

	-- Improvement Games
	use 'ThePrimeagen/vim-be-good'


end)
