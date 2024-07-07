vim9script noclear

# defaults:
if !exists('g:elevator#timeout_msec')
  g:elevator#timeout_msec = 2000
endif
if !exists('g:elevator#width')
  g:elevator#width = 1
endif
if !exists('g:elevator#show_on_enter')
  g:elevator#show_on_enter = false
endif
if !exists('g:elevator#highlight')
  g:elevator#highlight = ''
endif

if !exists('g:elevator#hidden')
  g:elevator#hidden = false
endif

var s_state = {
  scrolloff: -1,
  screenrow: -1,
  topline: -1,
  dragging: false,
  scrolled_winid: -1,
  popup_id: -1,
  timer_id: -1,
}

def S__clamp(value__a: number, min__a: number, max__a: number): number
  if value__a < min__a
    return min__a
  elseif value__a > max__a
    return max__a
  else
    return value__a
  endif
enddef

def S__calculate_scale(): float
  var winheight = winheight(win_getid())
  return 1.0 * winheight / (line('$', win_getid()) + winheight)
enddef

export def Toggle()
  if g:elevator#hidden
    Show(win_getid())
  else
    S__close()
  endif
  g:elevator#hidden = !g:elevator#hidden
enddef

export def Show(winid__a: number)
  if g:elevator#hidden
    return
  endif

  S__stop_timer()

  if winid__a == 0 # over command line
    var mousepos = getmousepos()
    # find window above mouse cursor:
    for wininfo in getwininfo()
      if (
        wininfo.winrow + wininfo.height + &cmdheight == &lines &&
        wininfo.wincol < mousepos.screencol && wininfo.wincol + wininfo.width > mousepos.screencol
      )
        s_state.scrolled_winid = wininfo.winid
        break
      endif
    endfor
  else
    s_state.scrolled_winid = winid__a
  endif

  if s_state.popup_id == -1
    s_state.popup_id = popup_create('', {
      pos: 'topleft',
      minwidth: g:elevator#width,
      dragall: true,
      zindex: 1,
      highlight: g:elevator#highlight,
    })
  endif

  S__set_geometry()
  S__restart_timer()
enddef

def S__stop_timer()
  if s_state.timer_id != -1
    timer_stop(s_state.timer_id)
    s_state.timer_id = -1
  endif
enddef

def S__restart_timer()
  S__stop_timer()
  if g:elevator#timeout_msec > 0
    s_state.timer_id = timer_start(g:elevator#timeout_msec, (_) => S__close())
  endif
enddef

def S__close()
  popup_close(s_state.popup_id)
  s_state.popup_id = -1
  s_state.timer_id = -1
enddef

export def S__set_geometry()
  var wininfo = getwininfo(s_state.scrolled_winid)[0]
  var scale = S__calculate_scale(s_state.scrolled_winid)
  echomsg scale
  if scale >= 1.0
    S__close()
    return
  endif

  var popup_height = S__clamp((wininfo.height * scale)->round()->float2nr(), 1, wininfo.height)
  var popup_offset = S__clamp(((wininfo.topline - 1) * scale)->round()->float2nr(), 0, wininfo.height - popup_height)

  popup_setoptions(s_state.popup_id, {
    col: wininfo.wincol + wininfo.width - g:elevator#width,
    line: wininfo.winrow + wininfo.winbar + popup_offset,
    minheight: popup_height,
  })
enddef
