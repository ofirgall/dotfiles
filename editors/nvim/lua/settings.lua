---@diagnostic disable: assign-type-mismatch
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.softtabstop = 4
opt.cursorline = true
opt.ignorecase = true
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.wrap = true
opt.undofile = true -- enable persistent undo
opt.scrolloff = 4 -- minimal number of screen lines to keep above and below the cursor.
opt.updatetime = 100 -- mainly for trld.nvim which utilize CursorHold autocmd
opt.formatoptions:append('cro') -- continue comments when going down a line
opt.sessionoptions:remove('options') -- don't save keymaps and local options
opt.foldlevelstart = 99 -- no auto folding
opt.mouse = 'a' -- Enable mouse when guest are using my nvim
opt.signcolumn = 'yes:1' -- Enable 1 signs in the column
opt.cmdheight = 0
opt.report = 2147483647 -- Don't report yanked/deleted lines
opt.diffopt:append('linematch:60')

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
