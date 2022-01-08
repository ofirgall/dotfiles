
" Remote .vimrc
:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set cursorline
:set ignorecase
:set splitright
:set splitbelow
nnoremap <silent> n jzzn
nnoremap <silent> N kzzN
nmap Q <nop>
nnoremap <F3> <cmd>let @/ = "not_gonna_find_this_______"<cr>
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" from now on only local settings
:set noswapfile

" Auto zz on jump
let g:jump_zz_thershold = 20
autocmd CursorMoved * call CheckMove()
function! CheckMove()
	if exists('s:lastLine')
		if (abs(s:lastLine - line(".")) >= g:jump_zz_thershold)
			" echo "Auto Recenter"
			normal zz
		endif
	endif
	let s:lastLine = line(".")
endfunction

" vim-visual-multi bindings
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<M-d>'
let g:VM_maps['Find Subword Under'] = '<M-d>'
let g:VM_highlight_matches = 'hi! link Search LspReferenceWrite' " Non selected matches
let g:VM_Mono_hl   = 'TabLine' " Cursor while in normal
let g:VM_Extend_hl = 'TabLineSel' " In Selection (NotUsed)
let g:VM_Cursor_hl = 'TabLineSel' " Cursor while in alt+d
let g:VM_Insert_hl = 'TabLineSel' " Cursor in insert

" for vim-session
" set sessionoptions+=winpos,terminal
set sessionoptions-=buffers,tabpages,options
let g:session_autosave = 'no' " Doesnt save unsaved session for some reason using autocmd instead
autocmd VimLeavePre * SaveSession
let g:session_autoload = 'yes'
let g:session_default_name = getcwd()

let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <M-Left> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-Down> :TmuxNavigateDown<cr>
nnoremap <silent> <M-Up> :TmuxNavigateUp<cr>
nnoremap <silent> <M-Right> :TmuxNavigateRight<cr>

let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
let g:XkbSwitchEnabled = 1

call plug#begin()
" https://github.com/rockerBOO/awesome-neovim

"""" LSP """"
Plug 'neovim/nvim-lspconfig'

" Complete engine
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
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
" Plug 'romgrk/nvim-treesitter-context' " Shows the context atm (class/function)
Plug 'SmiteshP/nvim-gps' " Shows context in status line
Plug 'lukas-reineke/indent-blankline.nvim' " Indent line helper
Plug 'numToStr/Comment.nvim' " Comments
Plug 'nvim-treesitter/nvim-treesitter-textobjects' " Movements base on treesitter

" Telescope
Plug 'nvim-lua/plenary.nvim' " Required by telescope and more
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder with alot of integration
Plug 'nvim-telescope/telescope-file-browser.nvim'

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
Plug 'ntpeters/vim-better-whitespace' " Whitespace trailing
Plug 'Pocco81/AutoSave.nvim' " Auto save
Plug 'romgrk/barbar.nvim' " Tabline
Plug 'xolox/vim-session' " Session Manager
Plug 'xolox/vim-misc' " For vim-session
Plug 'ethanholz/nvim-lastplace' " Save last place
Plug 'mg979/vim-visual-multi' " Multi cursors
Plug 'mizlan/iswap.nvim' " Swap arguments, elements
Plug 'christoomey/vim-tmux-navigator' " Navigate in panes integrated to vim
Plug 'rhysd/devdocs.vim' " Open DevDocs from nvim
Plug 'lyokha/vim-xkbswitch' " Switch to english for normal mode

" TODO: https://github.com/michaelb/sniprun
" TODO: motion
" TODO: https://github.com/AckslD/nvim-revJ.lua

" Improvment Games
Plug 'ThePrimeagen/vim-be-good'

set encoding=UTF-8

call plug#end()

" syntax off " For TreeSitter Syntax

luafile $HOME/.config/nvim/design.lua
luafile $HOME/.config/nvim/lsp.lua
luafile $HOME/.config/nvim/telescope.lua
luafile $HOME/.config/nvim/chained_live_grep.lua
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
  -- TODO: different file, smart loop for bindings
  textobjects = {
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["gj"] = "@function.outer",
        ["]]"] = "@class.outer",
        ["]b"] = "@block.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["gJ"] = "@function.outer",
        ["]["] = "@class.outer",
        ["]B"] = "@block.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["gk"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[b"] = "@block.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["gK"] = "@function.outer",
        ["[]"] = "@class.outer",
        ["[B"] = "@block.outer",
      },
    },
  },
}

require("nvim-gps").setup()
-- require'treesitter-context'.setup{
--     enable = true,
--     throttle = true,
--     max_lines = 0,
-- }

---------------- MISC ----------------
require('gitsigns').setup{
}

require('Comment').setup{
}

require('nvim-autopairs').setup{
}

require('autosave').setup{
	clean_command_line_interval = 1000
}

require'nvim-lastplace'.setup{
}

END

" Bindings
" Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
nnoremap <C-l> <cmd>Telescope find_files<cr>
nnoremap KL <cmd>Telescope find_files<cr>
nnoremap <C-k><C-k> <cmd>lua chained_live_grep({})<CR>
nnoremap KK <cmd>lua chained_live_grep({})<CR>
nnoremap <C-k><C-d> <cmd>lua chained_live_grep({default_text = vim.fn.expand("<cword>")})<cr>
nnoremap KD <cmd>lua chained_live_grep({default_text = vim.fn.expand("<cword>")})<cr>
nnoremap <M-m> <cmd>lua require"telescope".extensions.file_browser.file_browser({cwd = vim.fn.expand("%:p:h")})<cr>
nnoremap <C-h> <cmd>Telescope quickfix<CR>
nnoremap <C-s> <cmd>Telescope buffers<CR>
nnoremap <C-a> <cmd>Telescope oldfiles<CR>
nnoremap <C-x> <cmd>Telescope command_history<CR>
nnoremap <leader>gs <cmd>Telescope git_status<CR>
nnoremap <leader>gc <cmd>Telescope git_branches<CR>
" nnoremap <leader>gh <cmd>lua require('telescope.builtin').git_bcommits({git_command = {'git', 'log', '--pretty=format:%h %ad \| %sd [%an]', '--abbrev-commit', '--date=short'}})<CR>
nnoremap <leader>gh <cmd>lua require('telescope.builtin').git_bcommits()<CR>
" nnoremap <leader>gH <cmd>lua require('telescope.builtin').git_commits({git_command = {'git', 'log', '--pretty=format:%h %s', '--abbrev-commit', '--date=short'}})<CR>
nnoremap <leader>gH <cmd>lua require('telescope.builtin').git_commits()<CR>
nnoremap gD <cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols({default_text = vim.fn.expand("<cword>")})<cr>
nnoremap <A-s> <cmd>DevDocsUnderCursor<cr>
" Tabline binds
" nnoremap <silent> <A-s> <cmd>BufferPick<CR>
nnoremap <silent> Q <cmd>BufferClose<CR>
nnoremap <silent> <A-q> <cmd>BufferClose<CR>
nnoremap <silent> <A-,> <cmd>BufferPrevious<CR>
nnoremap <silent> <A-.> <cmd>BufferNext<CR>
nnoremap <silent> <A-<> <cmd>BufferMovePrevious<CR>
nnoremap <silent> <A->> <cmd>BufferMoveNext<CR>
nnoremap <silent> g1 <cmd>BufferGoto 1<CR>
nnoremap <silent> g2 <cmd>BufferGoto 2<CR>
nnoremap <silent> g3 <cmd>BufferGoto 3<CR>
nnoremap <silent> g4 <cmd>BufferGoto 4<CR>
nnoremap <silent> g5 <cmd>BufferGoto 5<CR>
nnoremap <silent> g6 <cmd>BufferGoto 6<CR>
nnoremap <silent> g7 <cmd>BufferGoto 7<CR>
nnoremap <silent> g8 <cmd>BufferGoto 8<CR>
nnoremap <silent> g9 <cmd>BufferGoto 9<CR>
nnoremap <silent> g0 <cmd>BufferLast<CR>

""""""" Tmux integration """"""""
" Set title of the file
" autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window nv:" . fnamemodify(getcwd(), ":~:."))
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window nvim")
autocmd QuitPre * call system("tmux rename-window zsh")

function!   QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
	exec "cclose"
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction

command! QuickFixOpenAll call QuickFixOpenAll()
