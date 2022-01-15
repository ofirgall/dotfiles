-----------------------------------------------------------
-- multi cursor
-----------------------------------------------------------

-- https://github.com/mg979/vim-visual-multi

vim.cmd([[
let g:VM_highlight_matches = 'hi! link Search LspReferenceWrite' " Non selected matches
let g:VM_Mono_hl   = 'TabLine' " Cursor while in normal
let g:VM_Extend_hl = 'TabLineSel' " In Selection (NotUsed)
let g:VM_Cursor_hl = 'TabLineSel' " Cursor while in alt+d
let g:VM_Insert_hl = 'TabLineSel' " Cursor in insert
]])
