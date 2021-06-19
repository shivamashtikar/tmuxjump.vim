if get(g:, 'tmuxjump_loaded')
    finish
endif

let g:scripts_dir = expand('<sfile>:h:h').'/scripts/'
let g:script_path= g:scripts_dir . 'capture.sh'

function! tmuxjump#jump_to_file(fileWithPos) abort
  let l:list = split(a:fileWithPos,':')
  let l:file_name = l:list[0]
  if !filereadable(l:file_name)
      return
  endif
  execute 'e ' . l:file_name
  if len(l:list) == 2
    norm l:list[1]
  elseif len(l:list) == 3
    execute "norm " . l:list[1] . "G" . l:list[2] . "|"
  endif
endfunction

function! tmuxjump#capture_and_jump(bang) abort

  let l:is_in_tmux = system('[[ "$TERM" =~ "screen" && "$TERM_PROGRAM" == "tmux" ]] && echo "1"')
  if !l:is_in_tmux
    echohl WarningMsg
    echo "TmuxJump.vim: Not in tmux session"
    echohl None
    return
  endif

  let l:capturedFiles = system('sh '. g:script_path)
  if l:capturedFiles == ""
    echohl WarningMsg
    echo "TmuxJump.vim: Found no file paths"
    echohl None
    return
  endif

  let l:list = uniq(reverse(split(l:capturedFiles, '\n')))
  let l:name = 'Sibling pane files'
  let l:prompt = 'TmuxJump> '
  let l:action = ''
  let l:valid_keys = ['enter']
  let l:fzf_options = [
        \ '--no-multi',
        \ '--prompt', l:prompt,
        \ '--nth', '1',
        \ '--no-sort',
        \]
  call fzf#run(fzf#wrap(
        \ {
        \   'source': l:list,
        \   'sink': { module -> tmuxjump#jump_to_file( module) },
        \   'options': l:fzf_options,
        \ },
        \)) 
endfunction

command! -bang -nargs=* TmuxJumpFile call tmuxjump#capture_and_jump(<bang>0)

let g:tmuxjump_loaded = v:true
