#!/usr/bin/env bash
# Toggle a markdown checkbox on the current line: [ ] <-> [x].
# Used from Helix via `:pipe` (keymap `space t`): Helix sends the selected
# line on stdin and replaces it with this script's stdout. printf (no trailing
# newline) so the toggle doesn't insert a blank line.
line="$(cat)"
if [[ "$line" == *"[ ]"* ]]; then
  printf '%s' "${line/\[ \]/[x]}"
elif [[ "$line" == *"[x]"* ]]; then
  printf '%s' "${line/\[x\]/[ ]}"
else
  printf '%s' "$line"
fi
