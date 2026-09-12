#!/usr/bin/env bash
# Pick a file (fd | fzf), open in $EDITOR. Used by kitty leader: <space> and f f.
set -euo pipefail
file=$(fd --type f --hidden --exclude .git | fzf --height=100% --reverse --prompt='files> ') || exit 0
[ -n "${file:-}" ] && exec "${EDITOR:-nvim}" "$file"
