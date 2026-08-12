#!/usr/bin/env bash
# Wrapper for tmux-copycat git-hash / sha search
"$TMUX_PLUGIN_MANAGER_PATH/tmux-copycat/scripts/copycat_mode_start.sh" "\b([0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64})\b"
