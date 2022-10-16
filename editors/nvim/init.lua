-- vim.g.did_load_filetypes = 0 -- dont load filetypes.vim we are loading filetypes.nvim instead

require('settings')
require('plugin_list')
require('autocmds')
require('utils')
require('keymaps')
require('impatient') -- Load impatient.nvim to accelerate boot
require('ui')
require('plugins').setup()

vim.cmd([[
source $HOME/.config/nvim/vim/file_util.vim
source $HOME/.config/nvim/vim/utils.vim
source $HOME/.config/nvim/vim/open_in_browser.vim
]])
