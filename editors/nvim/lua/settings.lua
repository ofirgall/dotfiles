
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

-- Highlight on yank
cmd [[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank({timeout=350, higroup='Visual'})
	augroup end
]]
