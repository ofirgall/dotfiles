-- Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
local cmd = vim.cmd

----------------------------------------------------------------------------------
--
-- This file contains the custom keymaps.
-- Keymaps are set by plugins, to all of the keymaps use :ListKeys
--
-- I tried to stick as close as I can to the vim key mantra.
-- Keybinds are acronyms of the action and will be marked in capital in the comment
--
-- Shift expanding the action to workspace
-- Shift reversing the action (like vim)
--
-- Binds that start with shift, reverse the shift action (to keep shift pressed)
--
----------------------------------------------------------------------------------

-----------------------------------
--           BUILTIN             --
-----------------------------------
map('n', 'n', 'nzz', default_opts) -- Auto recenter after n
map('n', 'N', 'Nzz', default_opts) -- Auto recenter after N
map('n', '<F3>', '<cmd>let @/ = "not_gonna_find_this_______"<cr>', default_opts) -- Disable find highlight
map('n', '<C-o>', '<C-o>zz', default_opts) -- Recenter after C-o
map('n', '<C-i>', '<C-i>zz', default_opts) -- Recenter after C-i
map('v', '<Enter>', 'y', default_opts) -- yank with Enter in visual mode
map('i', '<C-k>', '<C-O>o', default_opts) -- Insert new line in insert mode
map('n', '<M-v>', '"+y', default_opts) -- Start copy to os clipboard
map('n', '<M-y>', '"+y', default_opts) -- Start copy to os clipboard

-- Remap space as leader key
map('', '<Space>', '<Nop>', default_opts) -- Unmap space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

map('n', '<M-r>', '<cmd>echo "Current File Reloaded!"<cr><cmd>luafile %<cr>', default_opts) -- Reload current luafile

-- Remove arrows in normal mode
map('n', '<Left>', '<nop>', default_opts)
map('n', '<Right>', '<nop>', default_opts)
map('n', '<Up>', '<nop>', default_opts)
map('n', '<Down>', '<nop>', default_opts)

-- Move through wrap lines
map('', 'j', 'v:count ? "j" : "gj"', {noremap = true, expr=true})
map('', 'k', 'v:count ? "k" : "gk"', {noremap = true, expr=true})

-- Toggle spell check
map('n', '<F11>', ':set spell!<cr>', default_opts)
map('i', '<F11>', '<C-O>:set spell!<cr>', default_opts)

-- Naviagte in panes + splits (requires vim-tmux-navigator)
map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', default_opts)
map('n', '<M-Left>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<M-Down>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<M-Up>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<M-Right>', '<cmd>TmuxNavigateRight<cr>', default_opts)

-----------------------------------
--          MISC PLUGINS         --
-----------------------------------
map('n', '<F5>', '<cmd>UndotreeToggle<CR>', default_opts) -- Toggle undotree

-- Mutli Cursors Binds alt+d (like ctrl+d in subl)
cmd([[
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<M-d>'
let g:VM_maps['Find Subword Under'] = '<M-d>']]
)

-- Adding <leader> prefix for sandwich to avoid conflicting with lightspeed
vim.g.sandwich_no_default_key_mappings = 1
-- add
map('', '<leader>sa', '<Plug>(sandwich-add)', default_opts)
-- delete
map('n', '<leader>sd', '<Plug>(sandwich-delete)', default_opts)
map('x', '<leader>sd', '<Plug>(sandwich-delete)', default_opts)
map('n', '<leader>sdb', '<Plug>(sandwich-delete-auto)', default_opts)
-- replace
map('n', '<leader>sr', '<Plug>(sandwich-replace)', default_opts)
map('x', '<leader>sr', '<Plug>(sandwich-replace)', default_opts)
map('n', '<leader>srb', '<Plug>(sandwich-replace-auto)', default_opts)

-----------------------------------
--        CODE NAVIGATION        --
-----------------------------------
live_grep_raw = function(opts)
	opts = opts or {}
	opts.prompt_title = 'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"'

	require('telescope').extensions.live_grep_raw.live_grep_raw(opts)
end
map('n', 'KR', '<cmd>Telescope resume<cr>', default_opts) -- Resume last telescope
map('n', 'KL', '<cmd>lua require("telescope.builtin").find_files({hidden=true, follow=true})<cr>', default_opts)
map('n', 'KK', '<cmd>lua live_grep_raw()<CR>', default_opts)
map('n', 'Kk', '<cmd>lua live_grep_raw({default_text = \'-g"\' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. \'/*" \'})<CR>', default_opts)
map('n', 'KD', '<cmd>lua live_grep_raw({default_text = vim.fn.expand("<cword>")})<CR>', default_opts)
map('n', 'Kd', '<cmd>lua live_grep_raw({default_text = vim.fn.expand("<cword>") .. \' -g"\' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. \'/*"\'})<CR>', default_opts)
map('n', '<C-s>', '<cmd>Telescope buffers<CR>', default_opts)
map('n', '<C-a>', '<cmd>Telescope oldfiles<CR>', default_opts)
map('n', '<C-x>', '<cmd>Telescope command_history<CR>', default_opts)
map('n', '<A-s>', '<cmd>DevDocsUnderCursor<cr>', default_opts)

-----------------------------------
--             LSP               --
-----------------------------------
-- Builtin LSP Binds
map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {silent = true, noremap = true}) -- Format code

-- Telescope LSP Binds
map('n', 'gd', "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>", {silent = true, noremap = true}) -- Go to Definition
map('n', 'gD', '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols({default_text = vim.fn.expand("<cword>")})<cr>', default_opts) -- (Go) search Definition under current word
map('n', 'gi', "<cmd>lua require'telescope.builtin'.lsp_implementations{}<CR>", {silent = true, noremap = true}) -- Go to Implementation

map('n', 'gs', "<cmd>lua require'telescope.builtin'.lsp_document_symbols{}<CR>", {silent = true, noremap = true}) -- Go Symbols
map('n', 'gS', "<cmd>lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<CR>", {silent = true, noremap = true}) -- Go workspace (S)ymbols
map('n', 'gr', "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>", {silent = true, noremap = true}) -- Go to References
map('n', 'gp', "<cmd>lua require'telescope.builtin'.diagnostics{bufnr=0}<CR>", {silent = true, noremap = true}) -- Go to Problems
map('n', 'gP', "<cmd>lua require'telescope.builtin'.diagnostics{}<CR>", {silent = true, noremap = true}) -- Go to workspace (P)roblems

-- illumante
map('n', '<C-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', {noremap=true}) -- jump to Next occurence of var on cursor
map('n', '<C-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', {noremap=true}) -- jump to Previous occurence of var on cursor

-- Lsp UI
map('n', '<F2>', '<cmd>Lspsaga rename<cr>', {silent = true, noremap = true}) -- Rename symbols with F2
map('n', '<F4>', '<cmd>Lspsaga code_action<cr>', {silent = true, noremap = true}) -- Code action with F4
map('n', 'KJ',  '<cmd>Lspsaga hover_doc<cr>', {silent = true, noremap = true}) -- Trigger hover (KJ is fast to use)
map('n', '<leader>d',  '<cmd>Neogen<cr>', {silent = true, noremap = true}) -- Document function
map('n', '<leader>p', '<cmd>Lspsaga show_line_diagnostics<cr>', {silent = true, noremap = true}) -- show Problem
map('n', ']p', '<cmd>Lspsaga diagnostic_jump_next<cr>', {silent = true, noremap = true}) -- next Problem
map('n', '[p', '<cmd>Lspsaga diagnostic_jump_prev<cr>', {silent = true, noremap = true}) -- prev Problem
map('n', '<C-u>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>', {}) -- scroll Up in document
map('n', '<C-d>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>', {}) -- scroll Down in Document

-----------------------------------
--             GIT               --
-----------------------------------
map('n', '<leader>gs', '<cmd>DiffviewOpen<CR>', default_opts) -- Git Status
map('n', '<leader>gc', '<cmd>Telescope git_branches<CR>', default_opts) -- Git checkout
map('n', '<leader>gh', '<cmd>DiffviewFileHistory<CR>', default_opts) -- Git History
map('n', '<leader>gH', '<cmd>DiffviewFileHistory .<CR>', default_opts) -- Git workspace History

-- apply patches in 3 way split diff aka :SolveConflict
map('n', '<C-[>', '<cmd>diffget //2<CR>', default_opts) -- Apply left change
map('n', '<C-]>', '<cmd>diffget //3<CR>', default_opts) -- Apply right change

-----------------------------------
--             UI                --
-----------------------------------
-- File Sidebar
map('n', '<M-m>', '<cmd>NvimTreeToggle<cr>', default_opts)
map('n', '<M-n>', '<cmd>NvimTreeFocus<cr>', default_opts)

-- Tabline binds
map('n', 'Q', '<cmd>BufferClose!<CR>', default_opts) -- shift+Quit to close current tab
map('n', '<A-q>', '<cmd>BufferClose!<CR>', default_opts) -- alt+Quit to close current tab
map('n', '<A-,>', '<cmd>BufferPrevious<CR>', default_opts) -- Alt+, (<) to move to left
map('n', '<A-.>', '<cmd>BufferNext<CR>', default_opts) -- Alt+. (>) to move to right
map('n', '<A-<>', '<cmd>BufferMovePrevious<CR>', default_opts) -- Alt+Shift+< grab to with you to left
map('n', '<A->>', '<cmd>BufferMoveNext<CR>', default_opts) -- Alt+Shift+> grab to with you to right
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
