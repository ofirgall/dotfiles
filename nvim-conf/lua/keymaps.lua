-- Default bindings https://hea-www.harvard.edu/~fine/Tech/vi.html
local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
local cmd = vim.cmd

-- Remove arrows in normal mode
map('n', '<Left>', '<nop>', default_opts)
map('n', '<Right>', '<nop>', default_opts)
map('n', '<Up>', '<nop>', default_opts)
map('n', '<Down>', '<nop>', default_opts)

map('n', 'n', 'nzz', default_opts)
map('n', 'N', 'Nzz', default_opts)
map('n', '<F3>', '<cmd>let @/ = "not_gonna_find_this_______"<cr>', default_opts)
map('n', '<C-o>', '<C-o>zz', default_opts)
map('n', '<C-i>', '<C-i>zz', default_opts)
-- Move through wrap lines
map('', 'j', 'v:count ? "j" : "gj"', {noremap = true, expr=true})
map('', 'k', 'v:count ? "k" : "gk"', {noremap = true, expr=true})

map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', default_opts)
map('n', '<M-Left>', '<cmd>TmuxNavigateLeft<cr>', default_opts)
map('n', '<M-Down>', '<cmd>TmuxNavigateDown<cr>', default_opts)
map('n', '<M-Up>', '<cmd>TmuxNavigateUp<cr>', default_opts)
map('n', '<M-Right>', '<cmd>TmuxNavigateRight<cr>', default_opts)


map('n', 'KL', '<cmd>Telescope find_files<cr>', default_opts)
-- " TODO: when moving to lua init one prompt title
map('n', 'KK', '<cmd>lua require("telescope").extensions.live_grep_raw.live_grep_raw({prompt_title = \'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"\'})<CR>', default_opts)
map('n', 'Kk', '<cmd>lua require("telescope").extensions.live_grep_raw.live_grep_raw({default_text = \' -g"\' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. \'/*"\',prompt_title = \'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"\'})<CR>', default_opts)
map('n', 'KD', '<cmd>lua require("telescope").extensions.live_grep_raw.live_grep_raw({default_text = vim.fn.expand("<cword>"), prompt_title = \'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"\'})<CR>', default_opts)
map('n', 'Kd', '<cmd>lua require("telescope").extensions.live_grep_raw.live_grep_raw({default_text = vim.fn.expand("<cword>") .. \' -g"\' .. vim.fn.fnamemodify(vim.fn.expand("%"), ":.:h") .. \'/*"\', prompt_title = \'Live Grep Raw (-t[ty] include, -T exclude -g"[!] [glob])"\'})<CR>', default_opts)
-- map('n', '<M-m>', '<cmd>lua require"telescope".extensions.file_browser.file_browser({cwd = vim.fn.expand("%:p:h")})<cr>', default_opts)
map('n', '<M-m>', '<cmd>NvimTreeToggle<cr>', default_opts)
 -- map('n', '<C-h>', '<cmd>Telescope quickfix<CR> -- TODO: find a better bind if actually want to use it', default_opts)
map('n', '<C-s>', '<cmd>Telescope buffers<CR>', default_opts)
map('n', '<C-a>', '<cmd>Telescope oldfiles<CR>', default_opts)
map('n', '<C-x>', '<cmd>Telescope command_history<CR>', default_opts)
map('n', '<leader>gs', '<cmd>Telescope git_status<CR>', default_opts)
map('n', '<leader>gc', '<cmd>Telescope git_branches<CR>', default_opts)
-- map('n', '<leader>gh', '<cmd>lua require(\'telescope.builtin\').git_bcommits({git_command = {\'git\', \'log\', \'--pretty=format:%h %ad \| %sd [%an]\', \'--abbrev-commit\', \'--date=short\'}})<CR>', default_opts)
map('n', '<leader>gh', '<cmd>lua require(\'telescope.builtin\').git_bcommits()<CR>', default_opts)
-- map('n', '<leader>gH', '<cmd>lua require(\'telescope.builtin\').git_commits({git_command = {\'git\', \'log\', \'--pretty=format:%h %s\', \'--abbrev-commit\', \'--date=short\'}})<CR>', default_opts)
map('n', '<leader>gH', '<cmd>lua require(\'telescope.builtin\').git_commits()<CR>', default_opts)
map('n', 'gD', '<cmd>lua require(\'telescope.builtin\').lsp_dynamic_workspace_symbols({default_text = vim.fn.expand("<cword>")})<cr>', default_opts)
map('n', '<A-s>', '<cmd>DevDocsUnderCursor<cr>', default_opts)
-- Tabline binds
-- map('n', '<A-s>', '<cmd>BufferPick<CR>', default_opts)
map('n', 'Q', '<cmd>BufferClose<CR>', default_opts)
map('n', '<A-q>', '<cmd>BufferClose<CR>', default_opts)
map('n', '<A-,>', '<cmd>BufferPrevious<CR>', default_opts)
map('n', '<A-.>', '<cmd>BufferNext<CR>', default_opts)
map('n', '<A-<>', '<cmd>BufferMovePrevious<CR>', default_opts)
map('n', '<A->>', '<cmd>BufferMoveNext<CR>', default_opts)
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

cmd([[
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<M-d>'
let g:VM_maps['Find Subword Under'] = '<M-d>']]
)

-- Builtin LSP Binds --
-- map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {silent = true, noremap = true})
map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', {silent = true, noremap = true})

-- Telescope LSP Binds --
map('n', 'gd', "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>", {silent = true, noremap = true})
map('n', 'gi', "<cmd>lua require'telescope.builtin'.lsp_implementations{}<CR>", {silent = true, noremap = true})

map('n', 'gs', "<cmd>lua require'telescope.builtin'.lsp_document_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gS', "<cmd>lua require'telescope.builtin'.lsp_dynamic_workspace_symbols{}<CR>", {silent = true, noremap = true})
map('n', 'gr', "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>", {silent = true, noremap = true})
map('n', 'gp', "<cmd>lua require'telescope.builtin'.diagnostics{bufnr=0}<CR>", {silent = true, noremap = true})
map('n', 'gP', "<cmd>lua require'telescope.builtin'.diagnostics{}<CR>", {silent = true, noremap = true})

-- illumante --
map('n', '<C-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', {noremap=true})
map('n', '<C-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', {noremap=true})


map('n', '<F2>', '<cmd>Lspsaga rename<cr>', {silent = true, noremap = true})
map('n', '<F4>', '<cmd>Lspsaga code_action<cr>', {silent = true, noremap = true})
map('n', 'gx', '<cmd>Lspsaga code_action<cr>', {silent = true, noremap = true})
map('x', 'gx', ':<c-u>Lspsaga range_code_action<cr>', {silent = true, noremap = true})
map('n', '<S-Space>',  '<cmd>Lspsaga hover_doc<cr>', {silent = true, noremap = true})
map('n', 'KJ',  '<cmd>Lspsaga hover_doc<cr>', {silent = true, noremap = true})
map('n', 'K<C-j>',  '<cmd>Neogen<cr>', {silent = true, noremap = true})
map('n', 'go', '<cmd>Lspsaga show_line_diagnostics<cr>', {silent = true, noremap = true})
map('n', ']p', '<cmd>Lspsaga diagnostic_jump_next<cr>', {silent = true, noremap = true})
map('n', '[p', '<cmd>Lspsaga diagnostic_jump_prev<cr>', {silent = true, noremap = true})
map('n', '<C-u>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>', {})
map('n', '<C-d>', '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>', {})

----- Adding c prefix for sandwich to avoid conflicting with lightspeed -----
cmd("let g:sandwich_no_default_key_mappings = 1")
-- TODO: lua api
cmd([[
" add
silent! map <unique> csa <Plug>(sandwich-add)

" delete
silent! nmap <unique> csd <Plug>(sandwich-delete)
silent! xmap <unique> csd <Plug>(sandwich-delete)
silent! nmap <unique> csdb <Plug>(sandwich-delete-auto)

" replace
silent! nmap <unique> csr <Plug>(sandwich-replace)
silent! xmap <unique> csr <Plug>(sandwich-replace)
silent! nmap <unique> csrb <Plug>(sandwich-replace-auto)
]])
