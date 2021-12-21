
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4

call plug#begin()

" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
" Plug 'tanvirtin/monokai.nvim'
Plug 'crusoexia/vim-monokai'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'lambdalisue/suda.vim/'

set encoding=UTF-8

call plug#end()

lua << END
require'lualine'.setup{options = {theme = 'gruvbox_dark'}}
END

colorscheme monokai
