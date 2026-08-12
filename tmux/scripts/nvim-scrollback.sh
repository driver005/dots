#!/usr/bin/env bash
# Open current pane scrollback in nvim.
# pane_index/pane_id must be passed as $1/$2 (tmux-expanded by the caller) -
# a literal "#{pane_index}"/"#{pane_id}" here is never expanded by tmux
# inside a plain script file.
log_file="/tmp/tmux-scrollback-$1-$2.log"
tmux capture-pane -J -S - -E -
tmux save-buffer "$log_file"
tmux delete-buffer
tmux new-window "nvim '$log_file'"
