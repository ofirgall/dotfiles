-- Stupid vim plugins that must be configured before packer loads them.

-- micarmst/vim-spellsync
vim.g.spellsync_enable_git_union_merge = 0
vim.g.spellsync_enable_git_ignore = 0

-- mg979/vim-visual-multi
vim.g.VM_highlight_matches = 'hi! link Search LspReferenceWrite' -- Non selected matches
vim.g.VM_Mono_hl           = 'TabLine' -- Cursor while in normal
vim.g.VM_Extend_hl         = 'TabLineSel' -- In Selection (NotUsed)
vim.g.VM_Cursor_hl         = 'TabLineSel' -- Cursor while in alt+d
vim.g.VM_Insert_hl         = 'TabLineSel' -- Cursor in insert

-- lyokha/vim-xkbswitch
vim.g.XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
vim.g.XkbSwitchEnabled = 1
vim.g.XkbSwitchSkipGhKeys = { 'gh', 'gH' }
