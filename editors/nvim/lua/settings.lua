
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
opt.formatoptions:append('cro') -- continue comments when going down a line
opt.mouse = 'a' -- Enable mouse when guest are using my nvim
opt.foldlevelstart = 99 -- no auto folding
opt.signcolumn = 'yes:1' -- Enable 2 signs in the column TODO: do 1 sign when undercurls will exits, remove E/W/H

-- Enable and disable mouse when gaining/losing focus to avoid the first click jump
vim.api.nvim_create_autocmd('FocusGained', {
	pattern = '*',
	callback = function()
		opt.relativenumber = true
		opt.mouse = 'a'
	end
})
vim.api.nvim_create_autocmd('FocusLost', {
	pattern = '*',
	callback = function()
		opt.relativenumber = false
		opt.mouse = ''
	end
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function() vim.highlight.on_yank({timeout=350, higroup='Visual'}) end
})

if vim.fn.has('wsl') == 1 then
	vim.g.clipboard = {
		name = "win32yank-wsl",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
		cache_enabled = false
	}
end
