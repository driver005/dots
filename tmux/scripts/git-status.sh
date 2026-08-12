#!/usr/bin/env bash
# Compact git branch + dirty-state indicator for the status bar.
# dir must be passed as $1 (tmux-expanded #{pane_current_path} by the caller).
dir="$1"
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    printf '%s*' "$branch"
else
    printf '%s' "$branch"
fi
