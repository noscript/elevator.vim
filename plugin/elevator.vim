vim9script

if exists('g:elevator_loaded')
  finish
endif
g:elevator_loaded = true

import autoload 'elevator.vim'

augroup Elevator
  autocmd WinScrolled,BufEnter,WinEnter * elevator#Show(expand('<amatch>')->str2nr())
augroup END
