#!/usr/bin/env bash
# Keep Chemacs2 + Doom Emacs + Spacemacs current. Idempotent, safe to re-run.
# Wired into a pacman hook (see hooks/50-emacs-update.hook) so it fires
# automatically on garuda-update (and any manual pacman -Syu, since
# garuda-update is a wrapper around pacman - there's no way to distinguish
# the two at the hook level, nor any reason to).
set -euo pipefail

CHEMACS_DIR="$HOME/.emacs.d"
DOOM_DIR="$HOME/.emacs.doom.d"
SPACEMACS_DIR="$HOME/.emacs.spacemacs.d"

if [ -e "$CHEMACS_DIR/chemacs.el" ]; then
  echo "==> Chemacs2"
  git -C "$CHEMACS_DIR" pull --ff-only
fi

if [ -e "$DOOM_DIR/bin/doom" ]; then
  echo "==> Doom Emacs (core + packages)"
  DOOMDIR="$HOME/.config/doom" "$DOOM_DIR/bin/doom" upgrade --force
fi

if [ -e "$SPACEMACS_DIR/.git" ]; then
  echo "==> Spacemacs (repo only - package updates need an interactive session:"
  echo "    SPC f e U inside emacs --with-profile spacemacs)"
  git -C "$SPACEMACS_DIR" pull --ff-only
fi
