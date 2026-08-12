#!/usr/bin/env bash
# Count all descendant processes of the pane's shell - flags orphaned/stuck
# background jobs at a glance. root_pid must be passed as $1
# (tmux-expanded #{pane_pid} by the caller).
root="$1"
count=0
queue="$root"
while [ -n "$queue" ]; do
    next=""
    for pid in $queue; do
        children=$(pgrep -P "$pid" 2>/dev/null)
        if [ -n "$children" ]; then
            count=$((count + $(printf '%s\n' "$children" | wc -l)))
            next="$next $children"
        fi
    done
    queue="$next"
done
printf '%d' "$count"
