#!/usr/bin/env bash
# Keep every editor/plugin manager in this repo current: LazyVim (nvim),
# Helix treesitter grammars, and Chemacs2/Doom/Spacemacs. tmux (TPM) is
# deliberately skipped here.
# Idempotent, safe to re-run. Wired into a pacman hook (see
# dotfiles-update.hook) so it fires automatically on garuda-update (and any
# manual pacman -Syu - garuda-update is just a wrapper around pacman, there's
# no way to tell the two apart at the hook level, nor any reason to).
set -uo pipefail

# Debounce: pacman wrappers like garuda-update or yay split updates into multiple
# transactions (e.g., official repos, then AUR). This causes hooks with Target=* 
# to fire multiple times. We skip execution if we ran in the last 5 minutes.
LOCKFILE="/tmp/.dotfiles-update.lock"
if [ -e "$LOCKFILE" ]; then
  # if lockfile is younger than 5 minutes
  if find "$LOCKFILE" -mmin -5 | grep -q .; then
    echo "==> dotfiles-update: skipping (already ran in the last 5 minutes)."
    exit 0
  fi
fi
touch "$LOCKFILE"

command_exists() {
  command -v "$1" &>/dev/null
}

if command_exists nvim; then
  echo "==> LazyVim plugins"
  nvim --headless "+Lazy! sync" +qa
fi

if command_exists hx; then
  echo "==> Helix treesitter grammars"
  hx --grammar fetch
  hx --grammar build
fi

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -x "$DOTS_DIR/emacs/emacs-update.sh" ]; then
  echo "==> Emacs (Chemacs2 / Doom / Spacemacs)"
  "$DOTS_DIR/emacs/emacs-update.sh"
fi
