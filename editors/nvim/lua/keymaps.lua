---@diagnostic disable: lowercase-global
-- Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
local map = vim.keymap.set
local default_opts = { silent = true }
local cmd = vim.cmd

----------------------------------------------------------------------------------
--
-- This file contains the custom keymaps.
-- Keymaps are set by plugins, to allNavigatekeymaps use :ListKeys
--
-- I tried to stick as close as I can to the vim key mantra.
-- Keybinds are acronyms of the action and will be marked in capital in the comment
--
-- Shift expanding the action to workspace
-- Shift reversing the action (like vim)
--
-- Binds that start with shift, reverse the shift action (to keep shift pressed)
-- Binds that are prefixed with <leader> are more rare
--
--
-- If you are new for nvim/vim I `<M-X>` is 'Alt+x', `<C-x>` is 'Ctrl+x'
--   `x` is 'x', `X` is Shift+X
-- map('MODE', 'BIND', 'ACTION', OPTS(most of them are no re-map and silent))
--
-- nvim is reading the binds through ANSI, so it has some limitation
--   it can't read Ctrl+Shift+KEY, but it can read Alt+Shift+Key.
--   You can see what vim reads with `sed -n l`
--
-- Notice that nvim is the last program that read the binds
--   System(GUI) -> Terminal -> tmux -> nvim
--
----------------------------------------------------------------------------------

-----------------------------------
--     KEYMAPS FROM PLUGINS      --
-----------------------------------
-- lightspeed.nvim: Default
-- gitsigns.nvim: git.lua
-- treesitter-textobjects: treesitter.lua

-----------------------------------
--           BUILTIN             --
-----------------------------------
map('n', '<M-r>', '<cmd>echo "Current File Reloaded!"<cr><cmd>luafile %<cr>', default_opts) -- Reload current luafile
map('n', 'n', 'nzz', default_opts) -- Auto recenter after n
map('n', 'N', 'Nzz', default_opts) -- Auto recenter after N
map('n', '<F3>', '<cmd>let @/ = "not_gonna_find_this_______"<cr>', default_opts) -- Disable find highlight
map('n', '<C-o>', '<C-o>zz', default_opts) -- Recenter after C-o
map('n', '<C-i>', '<C-i>zz', default_opts) -- Recenter after C-i
map('v', '<Enter>', 'y', default_opts) -- yank with Enter in visual mode
map('i', '<C-k>', '<C-O>o', default_opts) -- Insert new line in insert mode
map('', '<M-y>', '"+y', default_opts) -- Start copy to os clipboard E.g: M-yy will copy current line to os
map('', '<M-Y>', '"+y$', default_opts) -- Copy rest of the line to os clipboard like "Y" but for os clipboard
map('n', '<M-,>', '<cmd>tabprev<cr>', default_opts) -- Previous tabpage with Alt+, (<). NOT FILE TABS
map('n', '<M-.>', '<cmd>tabnext<cr>', default_opts) -- Next tabpage with Alt+. (>). NOT FILE TABS

-- Remap space as leader key
map('', '<Space>', '<Nop>', default_opts) -- Unmap space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Remove arrows in normal mode
map('n', '<Left>', '<nop>', default_opts)
map('n', '<Right>', '<nop>', default_opts)
map('n', '<Up>', '<nop>', default_opts)
map('n', '<Down>', '<nop>', default_opts)

-- Move through wrapped lines
map('', 'j', 'v:count ? "j" : "gj"', { silent = true, expr = true})
map('', 'k', 'v:count ? "k" : "gk"', { silent = true, expr = true})

-- Toggle spell check
map('n', '<F11>', ':set spell!<cr>', default_opts)
map('i', '<F11>', '<C-O>:set spell!<cr>', default_opts)

-----------------------------------
--             TMUX              --
-----------------------------------
-- Navigate in panes + splits (requires vim-tmux-navigator)
map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', default_opts)
map('n', '<M-Left>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<M-Down>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<M-Up>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<M-Right>', '<cmd>TmuxNavigateRight<cr>', default_opts)
-- Splits like tmux
map('n', '<M-e>', '<cmd>vsplit<cr>', default_opts)
map('n', '<M-o>', '<cmd>split<cr>', default_opts)

map('n', '<M-q>', '<cmd>q<cr>', default_opts)
map('n', '<M-w>', '<cmd>q<cr>', default_opts) -- close pane like tmux

-- Duplicate your view into split (MAX 2)
map('n', 'gV', function() split_if_not_exist(true) end, default_opts)
map('n', 'gX', function() split_if_not_exist(false) end, default_opts)

-----------------------------------
--          MISC PLUGINS         --
-----------------------------------
map('n', '<F5>', '<cmd>UndotreeToggle<CR>', default_opts) -- Toggle undotree
map('n', '<leader>b', '<cmd>Telescope buffers<CR>', default_opts) -- browse your open Buffers (tabs)
map('n', '<leader>o', '<cmd>Telescope oldfiles<CR>', default_opts) -- open Old files
map('n', '<leader>c', '<cmd>Telescope command_history<CR>', default_opts) -- history of Commands
map('n', '<leader>ss', '<cmd>Telescope spell_suggest<CR>', default_opts) -- history of Commands
map('n', '<leader>l', '<cmd>DevDocsUnderCursor<cr>', default_opts) -- Search current word in DevDocs
map('n', 'gx', '<cmd>call OpenInBrowser()<CR>', default_opts)

-- Mutli Cursors Binds alt+d (like ctrl+d in subl)
-- Add cursor down/up Alt+n/p (like ctrl+down/up in subl)
cmd([[
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<M-d>'
let g:VM_maps['Find Subword Under'] = '<M-d>'
let g:VM_maps['Add Cursor Down'] = '<M-n>'
let g:VM_maps['Add Cursor Up'] = '<M-p>'
]])

-- Adding <leader> prefix for sandwich to avoid conflicting with lightspeed
vim.g.sandwich_no_default_key_mappings = 1
local sandwich_opts = {}
-- add
map('n', '<leader>sa', '<Plug>(sandwich-add)', sandwich_opts)
-- delete
map('n', '<leader>sd', '<Plug>(sandwich-delete)', sandwich_opts)
map('x', '<leader>sd', '<Plug>(sandwich-delete)', sandwich_opts)
map('n', '<leader>sdb', '<Plug>(sandwich-delete-auto)', sandwich_opts)
-- replace
map('n', '<leader>sr', '<Plug>(sandwich-replace)', sandwich_opts)
map('x', '<leader>sr', '<Plug>(sandwich-replace)', sandwich_opts)
map('n', '<leader>srb', '<Plug>(sandwich-replace-auto)', sandwich_opts)

-----------------------------------
--        CODE NAVIGATION        --
-----------------------------------
escape_rg_text = function(text)
	text = text:gsub('%(', '\\%(')
	text = text:gsub('%)', '\\%)')
	text = text:gsub('%[', '\\%[')
	text = text:gsub('%]', '\\%]')
	text = text:gsub('%{', '\\%{')
	text = text:gsub('%}', '\\%}')
	text = text:gsub('"', '\\"')
	text = text:gsub('-', '\\-')
	text = text:gsub('+', '\\-')

	return text
end

live_grep_raw = function(opts, mode)
	opts = opts or {}
	opts.prompt_title = 'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"'
	if not opts.default_text then
		if mode then
			opts.default_text = '"' .. escape_rg_text(get_text(mode)) .. '"'
		else
			opts.default_text = '"'
		end
	end

	require('telescope').extensions.live_grep_raw.live_grep_raw(opts)
end

get_text = function(mode)
	current_line = vim.api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = vim.api.nvim_buf_get_mark(0, "<")
		end_pos = vim.api.nvim_buf_get_mark(0, ">")
	elseif mode == 'n' then
		start_pos = vim.api.nvim_buf_get_mark(0, "[")
		end_pos = vim.api.nvim_buf_get_mark(0, "]")
	end

	return string.sub(current_line, start_pos[2]+1, end_pos[2]+1)
end

map('n', 'KR', '<cmd>Telescope resume<cr>', default_opts) -- Resume last telescope
map('n', 'KL', function() require("telescope.builtin").find_files({hidden=true, follow=true}) end, default_opts) -- find files (ctrl+p)
map('n', 'Kd', function() require("telescope.builtin").find_files({hidden=true, follow=true, default_text = vim.fn.expand("<cword>")}) end, default_opts) -- find files (ctrl+p) starting with current word
map('v', 'KL', '<Esc><cmd>lua require("telescope.builtin").find_files({hidden=true, follow=true, default_text=get_visual_text()})<cr>', default_opts) -- find files text from visual
map('n', 'KJ', live_grep_raw, default_opts) -- search in all files (fuzzy finder)
map('v', 'KJ', '<Esc><cmd>lua live_grep_raw({}, "v")<cr>', default_opts) -- search in all files (default text is from visual)
map('n', 'KD', function() live_grep_raw({default_text = vim.fn.expand("<cword>")}) end, default_opts) -- Search in all files with current word inserted
map('n', 'KF', ':set opfunc=LiveGrepRawOperator<CR>g@', default_opts) -- Search in all files with word from move operator
vim.cmd("function! LiveGrepRawOperator(...) \n lua live_grep_raw({}, 'n') \n endfunction") -- used by `KF`
map('n', 'Kj', function() live_grep_raw({default_text = '-g"' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. '/*" '}) end, default_opts) -- Search in all files in your current directory
map('n', 'Kjd', function() live_grep_raw({default_text = vim.fn.expand("<cword>") .. ' -g"' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. '/*"'}) end, default_opts) -- Search in all files in your current directory + with your current word


-----------------------------------
--             LSP               --
-----------------------------------
-- Builtin LSP Binds
map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, default_opts) -- Format code
map('n', 'gD', vim.lsp.buf.declaration, default_opts) -- Go to Declaration

-- Telescope LSP Binds
map('n', 'gd', function()
	local ft = vim.api.nvim_buf_get_option(0, 'filetype')
	if ft == 'man' then
		vim.api.nvim_command(':Man ' .. vim.fn.expand('<cword>'))
	elseif ft == 'help' then
		vim.api.nvim_command(':help ' .. vim.fn.expand('<cword>'))
	else
		require'telescope.builtin'.lsp_definitions()
	end
	end, default_opts) -- Go to Definition

map('n', 'gvd', function() split_if_not_exist(true) require'telescope.builtin'.lsp_definitions{} end, default_opts) -- Go to Definition in Vsplit
map('n', 'gxd', function() split_if_not_exist(false) require'telescope.builtin'.lsp_definitions{} end, default_opts) -- Go to Definition in Xsplit
map('n', 'gKD', function() require("telescope.builtin").lsp_dynamic_workspace_symbols({default_text = vim.fn.expand("<cword>")}) end, default_opts) -- (Go) search Definition under current word
map('n', 'gi', require'telescope.builtin'.lsp_implementations, default_opts) -- Go to Implementation
map('n', 'gvi', function() split_if_not_exist(true) require'telescope.builtin'.lsp_implementations{} end, default_opts) -- Go to Implementation in Vsplit
map('n', 'gxi', function() split_if_not_exist(false) require'telescope.builtin'.lsp_implementations{} end, default_opts) -- Go to Implementation in Xsplit

map('n', 'gS', require'telescope.builtin'.lsp_document_symbols, default_opts) -- Go Symbols
map('n', 'gs', require'telescope.builtin'.lsp_dynamic_workspace_symbols, default_opts) -- Go workspace (S)ymbols
map('n', 'gr', require'telescope.builtin'.lsp_references, default_opts) -- Go to References
map('n', 'gp', function() require'telescope.builtin'.diagnostics{bufnr=0} end, default_opts) -- Go to Problems
map('n', 'gP', require'telescope.builtin'.diagnostics, default_opts) -- Go to workspace (P)roblems

-- illumante
map('n', '<C-n>', function() require"illuminate".next_reference{wrap=true} end, default_opts) -- jump to Next occurrence of var on cursor
map('n', '<C-p>', function() require"illuminate".next_reference{reverse=true,wrap=true} end, default_opts) -- jump to Previous occurrence of var on cursor

-- Lsp UI
map('n', '<F2>', '<cmd>Lspsaga rename<cr>', default_opts) -- Rename symbols with F2
map('n', '<F4>', '<cmd>Lspsaga code_action<cr>', default_opts) -- Code action with F4
map('n', 'KK',  '<cmd>Lspsaga hover_doc<cr>', default_opts) -- Trigger hover (KJ is fast to use)
map('n', '<leader>d',  '<cmd>Neogen<cr>', default_opts) -- Document function
map('n', '<leader>p', '<cmd>Lspsaga show_line_diagnostics<cr>', default_opts) -- show Problem
map('n', ']p', '<cmd>Lspsaga diagnostic_jump_next<cr>', default_opts) -- next Problem
map('n', '[p', '<cmd>Lspsaga diagnostic_jump_prev<cr>', default_opts) -- prev Problem
map('n', '<C-u>', function() require("lspsaga.action").smart_scroll_with_saga(-1) end, {}) -- scroll Up in document
map('n', '<C-d>', function() require("lspsaga.action").smart_scroll_with_saga(1) end, {}) -- scroll Down in Document

-----------------------------------
--             GIT               --
-----------------------------------
map('n', '<leader>gs', '<cmd>:G<CR>', default_opts) -- Open fugitive.vim (git status)
map('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', default_opts) -- Git Sdiff
map('n', '<leader>gS', '<cmd>DiffviewOpen HEAD^..HEAD<CR>', default_opts) -- Git Show
map('n', '<leader>gc', '<cmd>Telescope git_branches<CR>', default_opts) -- Git checkout
map('n', '<leader>gh', '<cmd>DiffviewFileHistory<CR>', default_opts) -- Git History
map('n', '<leader>gH', '<cmd>DiffviewFileHistory .<CR>', default_opts) -- Git workspace History
map('n', '<leader>gt', '<cmd>Flogsplit<CR>', default_opts) -- Git Tree
map('n', '<leader>hh', '<cmd>GitMessenger<CR>')
map('n', 'gh', ':set opfunc=GitHistoryOperator<CR>g@', default_opts) -- show Git History with operator, e.g: gh3<cr> shows the history of the 3 lines below
map('v', 'gh', '<Esc><cmd>lua git_history("v")<cr>', default_opts) -- show Git History with visual mode
vim.cmd("function! GitHistoryOperator(...) \n lua git_history('n') \n endfunction") -- used by `gh`

-- apply patches in 3 way split diff aka :SolveConflict
map('n', '<C-[>', '<cmd>diffget //2<CR>', default_opts) -- Apply left change
map('n', '<C-]>', '<cmd>diffget //3<CR>', default_opts) -- Apply right change

git_history = function(mode)
	current_line = vim.api.nvim_get_current_line()
	if mode == 'v' then
		start_pos = vim.api.nvim_buf_get_mark(0, "<")
		end_pos = vim.api.nvim_buf_get_mark(0, ">")
	elseif mode == 'n' then
		start_pos = vim.api.nvim_buf_get_mark(0, "[")
		end_pos = vim.api.nvim_buf_get_mark(0, "]")
	end

	start_line = start_pos[1]
	end_line = end_pos[1]

	vim.api.nvim_command('Git log -L' .. start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%'))
end

-----------------------------------
--             UI                --
-----------------------------------
-- File Sidebar
map('n', '<M-m>', '<cmd>NvimTreeToggle<cr>', default_opts)

-- Tabline binds
map('n', 'Q', '<cmd>BufferClose!<CR>', default_opts) -- shift+Quit to close current tab
map('n', 'g1', '<cmd>BufferGoto 1<CR>', default_opts)
map('n', 'g2', '<cmd>BufferGoto 2<CR>', default_opts)
map('n', 'g3', '<cmd>BufferGoto 3<CR>', default_opts)
map('n', 'g4', '<cmd>BufferGoto 4<CR>', default_opts)
map('n', 'g5', '<cmd>BufferGoto 5<CR>', default_opts)
map('n', 'g6', '<cmd>BufferGoto 6<CR>', default_opts)
map('n', 'g7', '<cmd>BufferGoto 7<CR>', default_opts)
map('n', 'g8', '<cmd>BufferGoto 8<CR>', default_opts)
map('n', 'g9', '<cmd>BufferGoto 9<CR>', default_opts)
map('n', 'g0', '<cmd>BufferLast<CR>', default_opts)
-- Tab control, tmux binds are "outer" Alt+h/l and vim is "inner" Alt+j/k
map('n', '<M-j>', '<cmd>BufferPrevious<CR>', default_opts) -- Alt+j to move to left
map('n', '<M-k>', '<cmd>BufferNext<CR>', default_opts) -- Alt+k to move to right
map('n', '<M-J>', '<cmd>BufferMovePrevious<CR>', default_opts) -- Alt+Shift+j grab to with you to left
map('n', '<M-K>', '<cmd>BufferMoveNext<CR>', default_opts) -- Alt+Shift+k grab to with you to right

-----------------------------------
--         REFACTORING           --
-----------------------------------
map('v', '<leader>rf', '<Esc><cmd>lua require("telescope").extensions.refactoring.refactors()<CR>', default_opts) -- open Refactor menu
map('n', '<leader>dp', function() require("refactoring").debug.printf({}) end, default_opts) -- add Debug Print
map('v', '<leader>dp', function() require("refactoring").debug.print_var({}) end, default_opts) -- add Debug Print
map('n', '<leader>dc', function() require("refactoring").debug.cleanup({}) end, default_opts) -- Clean Debug prints
