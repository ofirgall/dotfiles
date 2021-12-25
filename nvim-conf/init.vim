
" Remote .vimrc
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4

" from now on only local settings
:set noswapfile
:set winaltkeys=no

call plug#begin()
" https://github.com/rockerBOO/awesome-neovim

"""" LSP """"
Plug 'neovim/nvim-lspconfig'

" Complete engine
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
"Plug 'hrsh7th/cmp-cmdline' " TODO: need if its better tha wilder
Plug 'hrsh7th/nvim-cmp'
Plug 'dcampos/nvim-snippy'
Plug 'dcampos/cmp-snippy'
 
Plug 'tami5/lspsaga.nvim' " Sweet ui for rename + code action and hover doc
Plug 'RRethy/vim-illuminate' " Mark word on cursor

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
Plug 'kyazdani42/nvim-tree.lua' " File explorer
Plug 'ethanholz/nvim-lastplace' " Jump to last place file edited
Plug 'ntpeters/vim-better-whitespace' " Whitespace trailing
Plug 'Pocco81/AutoSave.nvim' " Auto save
Plug 'rktjmp/highlight-current-n.nvim' " Highlight matches

" TODO: tabline?
" TODO: yank text from vim to os/tmux clipboard (tmux.nvim maybe)
" TODO: motion
" TODO: https://github.com/mizlan/iswap.nvim
" TODO: https://github.com/danielpieper/telescope-tmuxinator.nvim
" TODO: https://github.com/AckslD/nvim-revJ.lua

" Improvment Games
Plug 'ThePrimeagen/vim-be-good'

set encoding=UTF-8

call plug#end()

syntax off " For TreeSitter Syntax

luafile $HOME/.config/nvim/design.lua
luafile $HOME/.config/nvim/lsp.lua
source $HOME/.config/nvim/wilder.vim

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
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}

---------------- MISC ----------------
require'nvim-tree'.setup {
}

require('gitsigns').setup{
}

require('Comment').setup{
}

require('nvim-autopairs').setup{
}

require'nvim-lastplace'.setup{
}

require'highlight_current_n'.setup{
  highlight_group = "IncSearch" -- highlight group name to use for highlight
}

require('autosave').setup{
	clean_command_line_interval = 1000
}

END

"""" Hightlight search """"
nmap n <Plug>(highlight-current-n-n)
nmap N <Plug>(highlight-current-n-N)

augroup ClearSearchHL
  autocmd!
  " You may only want to see hlsearch /while/ searching, you can automatically
  " toggle hlsearch with the following autocommands
  autocmd CmdlineEnter /,\? set hlsearch
  autocmd CmdlineLeave /,\? set nohlsearch
  " this will apply similar n|N highlighting to the first search result
  " careful with escaping ? in lua, you may need \\?
  autocmd CmdlineLeave /,\? lua require('highlight_current_n')['/,?']()
augroup END

" Bindings
" Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
nnoremap <C-l> <cmd>Telescope find_files<cr>
nnoremap <C-k> <cmd>Telescope live_grep<cr>
nnoremap <C-a> <cmd>Telescope buffers<cr>
nnoremap <C-m> <cmd>NvimTreeToggle<cr>

""""""" Tmux integration """"""""
" Set title of the file
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . fnamemodify(expand("%"), ":~:."))
autocmd QuitPre * call system("tmux rename-window zsh")

