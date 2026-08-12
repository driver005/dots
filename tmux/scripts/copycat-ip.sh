#!/usr/bin/env bash
# Wrapper for tmux-copycat IP-address search
"$TMUX_PLUGIN_MANAGER_PATH/tmux-copycat/scripts/copycat_mode_start.sh" "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"
