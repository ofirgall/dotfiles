""""" Adding c prefis for sandwich to avoid conflicting with lightspeed """""

let g:sandwich_no_default_key_mappings = 1

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
