#!/usr/bin/env bash
# Wrapper for tmux-plugins/tmux-sessionist kill session prompt.
# session_name/session_id must be passed as $1/$2 (tmux-expanded by the
# caller) - a literal "#{session_name}" here is never expanded by tmux,
# since format expansion only happens in the run-shell command string.
"$TMUX_PLUGIN_MANAGER_PATH/tmux-sessionist/scripts/kill_session_prompt.sh" "$1" "$2"
