vim9script

if exists('g:elevator_loaded')
  finish
endif
g:elevator_loaded = true

import autoload 'elevator.vim'

augroup Elevator
	autocmd!
	if exists('g:elevator#show_on_enter') && g:elevator#show_on_enter == v:true
		autocmd BufWinEnter * elevator#Show(win_getid())
		autocmd WinEnter * elevator#Show(win_getid())
	endif
	autocmd WinScrolled * elevator#Show(win_getid())
augroup END

command ElevatorToggle elevator#Toggle()
