#!/bin/bash

pattern=$1

function capture_panes() {
    local pane captured current_pane
    captured=""
    current_pane=$(tmux display -pt "${TMUX_PANE:?}" '#{pane_index}')

    for pane in $(tmux list-panes -F "#{pane_index}"); do
      if [[ $pane != $current_pane ]]; then
            captured+="$(tmux capture-pane -pJS - -t $pane)"
            captured+=$'\n'
      fi
    done

    echo "$captured" | grep -oiE "[\/]?([a-z\_\-]+\/)+[a-z.]+(.)*" | cut -d' ' -f1 | grep "$pattern" 
}

capture_panes
