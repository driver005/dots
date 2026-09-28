#!/usr/bin/env bash
# Build Lem (ncurses frontend) from source and wire the config symlink.
# Lem has no distro package, so: sbcl + qlot + `make ncurses`. Idempotent:
# safe to re-run (pulls the repo, rebuilds, relinks).
set -euo pipefail

LEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # dots/lem
SRC_DIR="${LEM_SRC_DIR:-$HOME/.local/src/lem}"
BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

command_exists() { command -v "$1" &>/dev/null; }

echo "==> Build dependencies"
if command_exists pacman; then
  # libvterm: optional, only for lem-terminal (build is non-fatal without it)
  sudo pacman -S --needed --noconfirm sbcl ncurses libvterm base-devel git curl fd
elif command_exists apt; then
  sudo apt install -y sbcl libncurses-dev libvterm-dev build-essential git curl fd-find
else
  echo "Error: no supported package manager (pacman or apt)." >&2
  exit 1
fi

echo "==> qlot (Lem pins its Lisp dependencies with it)"
if ! command_exists qlot; then
  mkdir -p "$BIN_DIR"
  curl -fsSL https://qlot.tech/installer | sh
fi
command_exists qlot || { echo "Error: qlot not on PATH after install." >&2; exit 1; }

echo "==> Lem source ($SRC_DIR)"
if [ -d "$SRC_DIR/.git" ]; then
  git -C "$SRC_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone https://github.com/lem-project/lem.git "$SRC_DIR"
fi

echo "==> Build (make ncurses, takes a few minutes)"
make -C "$SRC_DIR" ncurses

echo "==> lem binary -> $BIN_DIR/lem"
mkdir -p "$BIN_DIR"
ln -sfn "$SRC_DIR/lem" "$BIN_DIR/lem"

echo "==> config symlink (~/.lem -> $LEM_DIR)"
if [ -e "$HOME/.lem" ] && [ ! -L "$HOME/.lem" ]; then
  mv "$HOME/.lem" "$HOME/.lem.bak.$(date +%s)"
fi
ln -sfn "$LEM_DIR" "$HOME/.lem"

echo "Done. Run: lem"
