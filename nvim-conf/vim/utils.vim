
function! QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
	exec "cclose"
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction

command! QuickFixOpenAll call QuickFixOpenAll()

au FileType qf call AdjustWindowHeight(3, 3)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

" Auto zz on jump
let g:jump_zz_thershold = 20
" autocmd CursorMoved * call CheckMove()
function! CheckMove()
	if exists('s:lastLine')
		if (abs(s:lastLine - line(".")) >= g:jump_zz_thershold)
			" echo "Auto Recenter"
			normal zz
		endif
	endif
	let s:lastLine = line(".")
endfunction

command! ListKeys exec ":redir! @a> | :silent verbose map | :redir END | :new | :put a"

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
command! RenameFile call RenameFile()
