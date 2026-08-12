#!/usr/bin/env bash
# Markdown scratch popup
tmux display-popup -E -w 80% -h 80% "nvim '+setlocal buftype=nofile' '+setlocal filetype=markdown' /tmp/tmux-scratch.md"
