
vim.cmd([[
autocmd BufEnter * call system("tmux rename-window 'nv:" . fnamemodify(getcwd(), ":t") . "'")
autocmd QuitPre * call system("tmux set -w automatic-rename on")
]])
