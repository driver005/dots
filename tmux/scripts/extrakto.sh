#!/usr/bin/env bash
# Wrapper for laktak/extrakto
# pane_id must be passed as $1 (tmux-expanded by the caller) - a literal
# "#{pane_id}" here is never expanded by tmux inside a plain script file.
"$TMUX_PLUGIN_MANAGER_PATH/extrakto/scripts/open.sh" "$1"
