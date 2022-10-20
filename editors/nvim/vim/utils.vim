
command! ListKeys exec ":redir! @a> | :silent verbose map | :redir END | :new | :put a"
" command! ListKeys exec "Telescope keymaps"
