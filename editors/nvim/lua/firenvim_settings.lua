
local cmd = vim.cmd     				-- execute Vim commands
local exec = vim.api.nvim_exec			-- execute Vimscript
local fn = vim.fn       				-- call Vim functions
local g = vim.g         				-- global variables
local opt = vim.opt						-- global/buffer/windows-scoped options
local map = vim.api.nvim_set_keymap

opt.laststatus = 0
cmd('set guifont=Mono:h20')
cmd([[
let g:firenvim_config = {
    \ 'globalSettings': {
        \ 'alt': 'all',
    \  },
    \ 'localSettings': {
        \ '.*': {
            \ 'cmdline': 'neovim',
            \ 'content': 'text',
            \ 'priority': 0,
            \ 'selector': 'textarea',
            \ 'takeover': 'never',
        \ },
    \ }
\ }
]])
