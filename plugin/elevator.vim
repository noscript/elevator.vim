vim9script

if exists('g:elevator_loaded')
  finish
endif
g:elevator_loaded = true

import autoload 'elevator.vim'

augroup Elevator
  if exists('g:elevator#show_on_launch') && g:elevator#show_on_launch == v:true
    autocmd BufEnter * elevator#Show(win_getid())
  endif
  autocmd WinScrolled * elevator#Show(win_getid())
augroup END
