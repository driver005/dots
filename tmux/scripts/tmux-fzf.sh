#!/usr/bin/env bash
# Wrapper for sainnhe/tmux-fzf
# client_tty must be passed as $1 (tmux-expanded by the caller) - a literal
# "#{client_tty}" here is never expanded by tmux inside a plain script file.
TMUX_FZF_CLIENT="$1" "$TMUX_PLUGIN_MANAGER_PATH/tmux-fzf/main.sh"
