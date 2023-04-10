" Copy File path
"
" Commands for copying the relative path, absolute path, name and directory of
" the current file.

function! SetGlobalCopyBuffer(content)
    call system('echo "' . a:content . '"| toclip')
endfunction

function! CopyRelativePath()
    call SetGlobalCopyBuffer(expand("%"))
    echo 'Relative path copied'
endfunction
command! CopyRelativePath :call CopyRelativePath()

function! CopyRelativePathAndLine()
    call SetGlobalCopyBuffer(expand("%") . ":" . line('.'))
    echo 'Relative path and line copied'
endfunction
command! CopyRelativePathAndLine :call CopyRelativePathAndLine()

function! CopyAbsolutePath()
    call SetGlobalCopyBuffer(expand("%:p"))
    echo 'Absolute path copied'
endfunction
command! CopyAbsolutePath :call CopyAbsolutePath()

function! CopyAbsolutePathAndLine()
    call SetGlobalCopyBuffer(expand("%:p") . ":" . line('.'))
    echo 'Absolute path and line copied'
endfunction
command! CopyAbsolutePathAndLine :call CopyAbsolutePathAndLine()

function! CopyFileName()
    call SetGlobalCopyBuffer(expand("%:t"))
    echo 'File name copied'
endfunction
command! CopyFileName :call CopyFileName()

function! CopyDirectoryPath()
    call SetGlobalCopyBuffer(expand("%:p:h"))
    echo 'Directory path copied'
endfunction
command! CopyDirectoryPath :call CopyDirectoryPath()
