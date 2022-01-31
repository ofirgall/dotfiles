
require('settings')
require('keymaps')
require('plugins/packer')
if vim.g.started_by_firenvim then
	require('firenvim_settings')
else
	require('plugins/vim-sessions')
	require('plugins/telescope')
	require('plugins/lsp-servers')
	require('plugins/tmux')
	require('plugins/treesitter')
	require('plugins/git')
end
require('plugins/design')
require('plugins/autocomplete')
require('plugins/visual-multi')
require('plugins/misc')

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
]])

