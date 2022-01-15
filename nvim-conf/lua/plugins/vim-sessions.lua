-----------------------------------------------------------
-- Sessions
-----------------------------------------------------------

-- https://github.com/xolox/vim-session


-- set sessionoptions+=winpos,terminal

vim.opt.sessionoptions:append({'buffers','tabpages','options'})
vim.cmd([[
let g:session_autosave = 'no' " Doesnt save unsaved session for some reason using autocmd instead
autocmd VimLeavePre * SaveSession
let g:session_autoload = 'yes'
let g:session_default_name = getcwd()
]])
