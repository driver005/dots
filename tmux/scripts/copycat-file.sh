#!/usr/bin/env bash
# Wrapper for tmux-plugins/tmux-copycat file path search
"$TMUX_PLUGIN_MANAGER_PATH/tmux-copycat/scripts/copycat_mode_start.sh" "(^|^\\.|[[:space:]]|[[:space:]]\\.|[[:space:]]\\.\\.|^\\.\\.)[[:alnum:]~_-]*/[][[:alnum:]_.#$%&+=/@-]*"
