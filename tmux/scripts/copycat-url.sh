#!/usr/bin/env bash
# Wrapper for tmux-plugins/tmux-copycat URL search
"$TMUX_PLUGIN_MANAGER_PATH/tmux-copycat/scripts/copycat_mode_start.sh" "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*"
