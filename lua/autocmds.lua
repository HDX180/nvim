vim.cmd [[
  augroup _format
    autocmd!
    " autocmd BufWritePre * :Format 
  augroup END

 augroup fswitch_h_file 
   au!
   au BufEnter *.h let b:fswitchdst = 'cpp,cc'
 augroup END

 augroup fswitch_cc_file
   au!
   au BufEnter *.cc let b:fswitchdst = 'h'
 augroup END

 augroup transparent_background
   au!
   au VimEnter * hi Normal ctermbg=NONE guibg=NONE
 augroup END

 augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord ctermbg=239 guibg=#504945
 augroup END
]]
