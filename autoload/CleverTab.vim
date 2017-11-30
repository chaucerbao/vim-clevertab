"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Otherwise, do completion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! CleverTab#Complete(type)
  if a:type == 'start'
    if has('autocmd')
      augroup CleverTabAu
        autocmd CursorMovedI * if pumvisible() == 0 && g:CleverTab#autocmd_set | let g:CleverTab#autocmd_set = 0 | pclose | call CleverTab#ClearAutocmds() | endif
        autocmd InsertLeave * if pumvisible() == 0 && g:CleverTab#autocmd_set | let g:CleverTab#autocmd_set = 0 | pclose | call CleverTab#ClearAutocmds() | endif
      augroup END
    endif
    if !exists('g:CleverTab#next_step_direction')
      echom 'Clevertab Start'
      let g:CleverTab#next_step_direction='0'
    endif
    let g:CleverTab#last_cursor_col=virtcol('.')
    let g:CleverTab#cursor_moved=0
    let g:CleverTab#eat_next=0
    let g:CleverTab#autocmd_set=1
    let g:CleverTab#stop=0
    return ''
  endif

  let g:CleverTab#cursor_moved=g:CleverTab#last_cursor_col!=virtcol('.')

  if a:type == 'tab' && !g:CleverTab#stop
    if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
      echom 'Regular Tab'
      let g:CleverTab#next_step_direction='0'
      let g:CleverTab#stop=1
      return "\<Tab>"
    endif

  elseif a:type == 'tab!' && !g:CleverTab#stop
    echom 'Forced Tab'
    let g:CleverTab#next_step_direction='0'
    let g:CleverTab#stop=1
    return "\<Tab>"

  elseif a:type == 'omni' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if &omnifunc != ''
      echom 'Omni Complete'
      let g:CleverTab#next_step_direction='N'
      let g:CleverTab#eat_next=1
      return "\<C-x>\<C-o>\<C-n>"
    endif

  elseif a:type == 'user' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if &completefunc != ''
      echom 'User Complete'
      let g:CleverTab#next_step_direction='N'
      let g:CleverTab#eat_next=1
      return "\<C-x>\<C-u>\<C-n>"
    endif

  elseif a:type == 'keyword' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom 'Keyword Complete'
    let g:CleverTab#next_step_direction='N'
    let g:CleverTab#eat_next=1
    return "\<C-x>\<C-n>\<C-n>"

  elseif a:type == 'dictionary' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom 'Dictionary Complete'
    let g:CleverTab#next_step_direction='N'
    let g:CleverTab#eat_next=1
    return "\<C-x>\<C-k>\<C-n>"

  elseif a:type == 'file' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom 'File Complete'
    let g:CleverTab#next_step_direction='N'
    let g:CleverTab#eat_next=1
    return "\<C-x>\<C-f>\<C-n>"

  elseif a:type == 'neocomplete' && !pumvisible() && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    echom 'NeoComplete'
    let g:CleverTab#next_step_direction='N'
    let g:CleverTab#eat_next=1
    return neocomplete#start_manual_complete()

  elseif a:type == 'neosnippet' && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    let g:neo_snip_x = neosnippet#mappings#expand_or_jump_impl()
    if neosnippet#expandable_or_jumpable()
      echom 'NeoSnippet'
      let g:CleverTab#next_step_direction='0'
      let g:CleverTab#stop=1
      return g:neo_snip_x
    endif
    return ''

  elseif a:type == 'ultisnips' && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    let g:ulti_x = UltiSnips#ExpandSnippet()
    if g:ulti_expand_res
      echom 'Ultisnips'
      let g:CleverTab#next_step_direction='0'
      let g:CleverTab#stop=1
      return g:ulti_x
    endif
    return ''

  elseif a:type == 'minisnip' && !g:CleverTab#cursor_moved && !g:CleverTab#stop
    if minisnip#ShouldTrigger()
      echom 'Minisnip'
      let g:CleverTab#next_step_direction='0'
      let g:CleverTab#stop=1
      return "x\<bs>\<esc>:call \minisnip#Minisnip()\<cr>"
    endif
    return ''

  elseif a:type == 'stop' || a:type == 'next'
    if g:CleverTab#stop || g:CleverTab#eat_next == 1
      let g:CleverTab#stop=0
      let g:CleverTab#eat_next=0
      return ''
    endif
    if g:CleverTab#next_step_direction == 'P'
      return "\<C-p>"
    elseif g:CleverTab#next_step_direction == 'N'
      return "\<C-n>"
    endif

  elseif a:type == 'prev'
    if g:CleverTab#next_step_direction == 'P'
      return "\<C-n>"
    elseif g:CleverTab#next_step_direction == 'N'
      return "\<C-p>"
    endif
  endif

  return ''
endfunction

" Presets
function! CleverTab#OmniFirst()
  inoremap <silent><Tab> <C-r>=CleverTab#Complete('start')<CR>
    \<C-r>=CleverTab#Complete('tab')<CR>
    \<C-r>=CleverTab#Complete('user')<CR>
    \<C-r>=CleverTab#Complete('omni')<CR>
    \<C-r>=CleverTab#Complete('file')<CR>
    \<C-r>=CleverTab#Complete('keyword')<CR>
    \<C-r>=CleverTab#Complete('dictionary')<CR>
    \<C-r>=CleverTab#Complete('stop')<CR>
  inoremap <silent><S-Tab> <C-r>=CleverTab#Complete('prev')<CR>
endfunction

function! CleverTab#KeywordFirst()
  inoremap <silent><Tab> <C-r>=CleverTab#Complete('start')<CR>
    \<C-r>=CleverTab#Complete('tab')<CR>
    \<C-r>=CleverTab#Complete('user')<CR>
    \<C-r>=CleverTab#Complete('keyword')<CR>
    \<C-r>=CleverTab#Complete('omni')<CR>
    \<C-r>=CleverTab#Complete('file')<CR>
    \<C-r>=CleverTab#Complete('dictionary')<CR>
    \<C-r>=CleverTab#Complete('stop')<CR>
  inoremap <silent><S-Tab> <C-r>=CleverTab#Complete('prev')<CR>
endfunction

function! CleverTab#NeoCompleteFirst()
  inoremap <silent><Tab> <C-r>=CleverTab#Complete('start')<CR>
    \<C-r>=CleverTab#Complete('tab')<CR>
    \<C-r>=CleverTab#Complete('user')<CR>
    \<C-r>=CleverTab#Complete('neocomplete')<CR>
    \<C-r>=CleverTab#Complete('omni')<CR>
    \<C-r>=CleverTab#Complete('file')<CR>
    \<C-r>=CleverTab#Complete('keyword')<CR>
    \<C-r>=CleverTab#Complete('dictionary')<CR>
    \<C-r>=CleverTab#Complete('stop')<CR>
  inoremap <silent><S-Tab> <C-r>=CleverTab#Complete('prev')<CR>
endfunction

function! CleverTab#ClearAutocmds()
  autocmd! CleverTabAu InsertLeave *
  autocmd! CleverTabAu CursorMovedI *
endfunction
