NVLOG = vim.env.NVLOG

require('settings')
require('before_packer')
require('plugin_list')
require('utils')
require('autocmds')
require('usercmds')
require('keymaps')
require('impatient') -- Load impatient.nvim to accelerate boot
require('ui')
require('plugins').setup()

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
]])
