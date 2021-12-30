
" Remote .vimrc
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set cursorline
:set smartcase
nnoremap <silent> n jzzn
nnoremap <silent> N kzzN
nmap Q <nop>
nnoremap <F3> <cmd>let @/ = "not_gonna_find_this_______"<cr>
nnoremap <CR> i<Escape>l
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" from now on only local settings
:set noswapfile

call plug#begin()
" https://github.com/rockerBOO/awesome-neovim

"""" LSP """"
Plug 'neovim/nvim-lspconfig'

" Complete engine
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline' " TODO: need if its better tha wilder
Plug 'hrsh7th/nvim-cmp'
Plug 'dcampos/nvim-snippy'
Plug 'dcampos/cmp-snippy'

Plug 'honza/vim-snippets' " Default snippets
Plug 'tami5/lspsaga.nvim' " Sweet ui for rename + code action and hover doc
Plug 'RRethy/vim-illuminate' " Mark word on cursor
Plug 'ray-x/lsp_signature.nvim' " Signature hint while typing
Plug 'onsails/lspkind-nvim' " Adding sweet ui for kind (function/var/method)

" TreeSitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground' " TreeSitter helper to customize
Plug 'tanvirtin/monokai.nvim' " Color theme (customized)
Plug 'romgrk/nvim-treesitter-context' " Shows the context atm (class/function)
Plug 'lukas-reineke/indent-blankline.nvim' " Indent line helper
Plug 'numToStr/Comment.nvim' " Comments

" Telescope
Plug 'nvim-lua/plenary.nvim' " Required by telescope and more
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder with alot of integration

" Status Line
Plug 'nvim-lualine/lualine.nvim' " Status line
Plug 'kyazdani42/nvim-web-devicons' " Web icons (more plugins using this)

" Git
Plug 'lewis6991/gitsigns.nvim' " Show git diff in the sidebar
" TODO: Get more git feature (merge diff and stuff like this)

" Wilder (command line)
Plug 'gelguy/wilder.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'romgrk/fzy-lua-native'

" Misc
Plug 'machakann/vim-sandwich' " Sandwich text (sa action)
Plug 'lambdalisue/suda.vim' " Sudo write/read (SudaWrite/Read)
Plug 'jdhao/better-escape.vim' " Escape insert mode fast (jk)
Plug 'windwp/nvim-autopairs' " Closes ("' etc.
Plug 'ellisonleao/glow.nvim' " Markdown preview
Plug 'ethanholz/nvim-lastplace' " Jump to last place file edited
Plug 'ntpeters/vim-better-whitespace' " Whitespace trailing
Plug 'Pocco81/AutoSave.nvim' " Auto save
Plug 'romgrk/barbar.nvim' " Tabline
Plug 'rmagatti/auto-session' " Session Manager
Plug 'mg979/vim-visual-multi' " Multi cursors

" TODO: motion
" TODO: https://github.com/mizlan/iswap.nvim
" TODO: https://github.com/danielpieper/telescope-tmuxinator.nvim
" TODO: https://github.com/AckslD/nvim-revJ.lua

" Improvment Games
Plug 'ThePrimeagen/vim-be-good'

set encoding=UTF-8

call plug#end()

" syntax off " For TreeSitter Syntax

luafile $HOME/.config/nvim/design.lua
luafile $HOME/.config/nvim/lsp.lua
" source $HOME/.config/nvim/wilder.vim

lua << END
---------------- TREE SITTER ---------------
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

---------------- Telescope ----------------
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    }
  },
  pickers = {
  },
  extensions = {
  }
}

---------------- MISC ----------------
require('gitsigns').setup{
}

require('Comment').setup{
}

require('nvim-autopairs').setup{
}

require'nvim-lastplace'.setup{
}

require('autosave').setup{
	clean_command_line_interval = 1000
}

require('auto-session').setup {
    auto_session_enable_last_session=false,
}

END

" Bindings
" Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
nnoremap <C-l> <cmd>Telescope find_files<cr>
nnoremap <C-k><C-k> <cmd>Telescope live_grep<cr>
nnoremap <C-k><C-d> <cmd>Telescope grep_string<CR>
nnoremap <C-m> <cmd>lua require('telescope.builtin').file_browser({cwd = vim.fn.expand("%:p:h")})<cr>
nnoremap <C-s> <cmd>Telescope buffers<CR>
nnoremap <C-a> <cmd>Telescope oldfiles<CR>
nnoremap <C-x> <cmd>Telescope command_history<CR>
nnoremap <leader>gs <cmd>Telescope git_status<CR>
nnoremap <leader>gc <cmd>Telescope git_branches<CR>
nnoremap <leader>gh <cmd>Telescope git_bcommits<CR>
" Tabline binds
nnoremap <silent> <A-s> <cmd>BufferPick<CR>
nnoremap <silent> Q <cmd>BufferClose<CR>
nnoremap <silent> <A-q> <cmd>BufferClose<CR>
nnoremap <silent> <A-,> <cmd>BufferPrevious<CR>
nnoremap <silent> <A-.> <cmd>BufferNext<CR>
nnoremap <silent> <A-<> <cmd>BufferMovePrevious<CR>
nnoremap <silent> <A->> <cmd>BufferMoveNext<CR>

""""""" Tmux integration """"""""
" Set title of the file
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window nv:" . fnamemodify(getcwd(), ":~:."))
autocmd QuitPre * call system("tmux rename-window zsh")

