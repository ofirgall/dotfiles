
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set nohlsearch

call plug#begin()

" TreeSitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
Plug 'nvim-treesitter/playground'
Plug 'tanvirtin/monokai.nvim'
Plug 'romgrk/nvim-treesitter-context'

" Telescope 
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lambdalisue/suda.vim/'
Plug 'jdhao/better-escape.vim'
Plug 'tpope/vim-commentary'
Plug 'Raimondi/delimitMate'

set encoding=UTF-8

call plug#end()

syntax off

lua << END
require'lualine'.setup{options = {theme = 'gruvbox_dark'}}

require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  sync_install = false,
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
	custom_captures = {
	}
  },
}

require'treesitter-context'.setup{
    enable = true, 
    throttle = true,
    max_lines = 0,
}

local monokai = require('monokai')
local palette = monokai.classic
monokai.setup {
    palette = {
		base2 = '#282923'
    },
    custom_hlgroups = {
		TSFunction = {
			fg = palette.green,
			style = 'none',
		},
		TSKeywordFunction = {
			fg = palette.aqua,
			style = 'italic',
		},
		TSParameter = {
			fg = palette.orange,
			style = 'italic',
		},
		TSMethod = {
			fg = palette.aqua,
			style = 'none',
		},
		TSConstructor = {
			fg = palette.aqua,
			style = 'none',
		},
		TSType = {
			fg = palette.green,
			style = 'none',
		},
		TSField = {
			fg = palette.pink,
			style = 'none',
		},
    }
}

END

