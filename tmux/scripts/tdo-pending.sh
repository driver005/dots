#!/usr/bin/env bash
# Pending-todo count for the status bar, via 2kabhishek/tdo. Defaults
# NOTES_DIR to ~/notes so it works even when the tmux server env lacks it.
command -v tdo >/dev/null 2>&1 || exit 0
export NOTES_DIR="${NOTES_DIR:-$HOME/notes}"
tdo --pending 2>/dev/null
