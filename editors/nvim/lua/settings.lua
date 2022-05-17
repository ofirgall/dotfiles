
local cmd = vim.cmd
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smarttab = true
opt.softtabstop = 4
opt.cursorline = true
opt.ignorecase = true
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.updatetime = 100 -- mainly for trld.nvim which utilize CursorHold autocmd

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function() vim.highlight.on_yank({timeout=350, higroup='Visual'}) end
})
