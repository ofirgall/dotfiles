
vim.g.did_load_filetypes = 1 -- dont load filetypes.vim we are loading filetypes.nvim instead

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
	require('plugins/debug')
end
require('plugins/vim-sessions')
require('plugins/design')
require('plugins/autocomplete')
require('plugins/visual-multi')
require('plugins/misc')

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
source $HOME/.config/nvim/vim/tabline.vim
source $HOME/.config/nvim/vim/open_in_browser.vim
]])

