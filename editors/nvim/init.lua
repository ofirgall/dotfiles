require('settings')
require('before_packer')
require('plugin_list')
require('autocmds')
require('usercmds')
require('utils')
require('keymaps')
require('impatient') -- Load impatient.nvim to accelerate boot
require('ui')
require('plugins').setup()

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
]])
