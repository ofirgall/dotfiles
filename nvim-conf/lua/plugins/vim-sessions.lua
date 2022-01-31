-----------------------------------------------------------
-- Sessions
-----------------------------------------------------------

-- https://github.com/xolox/vim-session


-- set sessionoptions+=winpos,terminal

if vim.g.started_by_firenvim then
	vim.cmd([[
	let g:session_autosave = 'no'
	let g:session_autoload = 'no'
	]])
else
	vim.opt.sessionoptions:append({'buffers','tabpages','options'})
	vim.cmd([[
	let g:session_autosave = 'no' " Doesnt save unsaved session for some reason using autocmd instead
	autocmd VimLeavePre * SaveSession
	let g:session_autoload = 'yes'
	let g:session_default_name = getcwd()
	]])
end
