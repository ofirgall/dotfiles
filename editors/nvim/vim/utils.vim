
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
" command! ListKeys exec "Telescope keymaps"

command! OsClipboard exec ":set clipboard=unnamedplus"
command! NoOsClipboard exec ":set clipboard="

function TabsOrSpaces()
	" Determines whether to use spaces or tabs on the current buffer.
	if getfsize(bufname("%")) > 256000
		" File is very large, just use the default.
		return
	endif

	let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
	let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^ "'))

	if numTabs > numSpaces
		setlocal noexpandtab
	endif
endfunction

" Tab or spaces by most in the buffer
autocmd BufReadPost * call TabsOrSpaces()
