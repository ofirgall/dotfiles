
require('settings')
require('utils')
require('plugins/packer')
require('keymaps')
require('impatient') -- Load impatient.nvim to accelerate boot
if vim.g.started_by_firenvim then
	require('firenvim_settings')
else
	require('plugins/telescope')
	require('plugins/lsp-servers')
	require('plugins/treesitter')
	require('plugins/git')
	require('plugins/neorg')
	require('plugins/hydra')
end
require('plugins/vim-sessions')
require('plugins/design')
require('plugins/autocomplete')
require('plugins/visual-multi')
require('plugins/misc')
if not vim.g.started_by_firenvim then
	require('plugins/debug') -- Must be loaded after design.lua for highlights
end

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
source $HOME/.config/nvim/vim/tabline.vim
source $HOME/.config/nvim/vim/open_in_browser.vim
]])

