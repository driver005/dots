#!/usr/bin/env bash
# Custom dev session (1amSimp1e sessions/*.sh pattern):
#   1: nvim (LazyVim)  2: claude  3: shell  4: opencode  5: todos (tdo)
# Each program window falls back to a shell on exit (exec bash) so closing
# the program does NOT close the window.
session="dev"
path="$HOME"
keep() { printf 'bash -c %q' "[ -f ~/.bashrc.secrets ] && source ~/.bashrc.secrets; $1; exec bash"; }

if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$path" -n "nvim"     "$(keep 'nvim')"
    tmux new-window  -t "$session" -c "$path" -n "claude"   "$(keep 'claude')"
    tmux new-window  -t "$session" -c "$path" -n "shell"
    tmux new-window  -t "$session" -c "$path" -n "opencode" "$(keep 'opencode')"
    tmux new-window  -t "$session" -c "$path" -n "todos"    "$(keep 'EDITOR=nvim NOTES_DIR="$HOME/notes" tdo')"
    tmux select-window -t "${session}:1"
fi

# switch if already inside tmux, otherwise attach
if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
else
    tmux attach-session -t "$session"
fi
