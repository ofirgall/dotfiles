
is_firenvim = vim.api.nvim_eval('exists("g:started_by_firenvim")')
require('settings')
require('keymaps')
require('plugins/packer')
if not is_firenvim then
	require('plugins/vim-sessions')
	require('plugins/telescope')
	require('plugins/lsp-servers')
	require('plugins/tmux')
	require('plugins/treesitter')
else
require('plugins/design')
require('plugins/autocomplete')
require('plugins/visual-multi')
require('plugins/misc')

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
]])
	vim.opt.laststatus = 0
	vim.cmd('set guifont=Iosevka:h25')
end
