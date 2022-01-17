
require('settings')
require('keymaps')
require('plugins/packer')
require('plugins/vim-sessions')
require('plugins/design')
require('plugins/telescope')
require('plugins/lsp-servers')
require('plugins/autocomplete')
require('plugins/visual-multi')
require('plugins/treesitter')
require('plugins/tmux')
require('plugins/misc')

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
source $HOME/.config/nvim/vim/sandwich.vim
]])
