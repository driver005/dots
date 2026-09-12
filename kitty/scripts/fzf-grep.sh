#!/usr/bin/env bash
# Grep (rg | fzf), open match in $EDITOR at line. Used by kitty leader: s g.
set -euo pipefail
sel=$(rg --line-number --no-heading --color=never --smart-case . \
      | fzf --height=100% --reverse --delimiter=: --nth=3.. --prompt='grep> ') || exit 0
[ -z "${sel:-}" ] && exit 0
file=${sel%%:*}
rest=${sel#*:}
line=${rest%%:*}
exec "${EDITOR:-nvim}" +"${line}" "$file"
