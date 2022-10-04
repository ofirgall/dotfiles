local opt = vim.opt
local api = vim.api

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
opt.sessionoptions:remove('options') -- don't save keymaps and local options
opt.foldlevelstart = 99 -- no auto folding
opt.mouse = 'a' -- Enable mouse when guest are using my nvim
opt.signcolumn = 'yes:1' -- Enable 1 signs in the column

config_autocmds = api.nvim_create_augroup('config', { clear = true })

-- Enable and disable mouse when gaining/losing focus to avoid the first click jump
api.nvim_create_autocmd('FocusGained', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		opt.mouse = 'a'
	end
})
api.nvim_create_autocmd('FocusLost', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		opt.mouse = ''
	end
})

-- Highlight on yank
api.nvim_create_autocmd('TextYankPost', {
	group = config_autocmds,
	pattern = '*',
	callback = function()
		vim.highlight.on_yank({ timeout = 350, higroup = 'Visual' })
	end
})

-- Auto spell files
api.nvim_create_autocmd('FileType', {
	group = config_autocmds,
	pattern = { 'markdown' },
	callback = function()
		vim.opt_local.spell = true
	end
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
