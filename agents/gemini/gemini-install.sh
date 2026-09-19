#!/usr/bin/env bash
# Symlink dots/gemini/GEMINI.md to ~/.gemini/GEMINI.md - gemini-cli/agy's
# global memory file, loaded into every session's context automatically
# (same mechanism as Claude Code's CLAUDE.md). It @imports the caveman,
# superpowers, i-have-adhd and no-ai-slop skill files directly, so they
# auto-load in agy the same way Claude Code's default-agent-rules plugin
# makes them auto-load there (see claude/claude-install.sh).
#
# Idempotent: safe to re-run. Backs up a pre-existing real file instead of
# clobbering it, matching the config-symlink pattern setup.sh already uses
# elsewhere (~/.config/doom, ~/.config/spacemacs, starship.toml).
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}/.gemini/GEMINI.md"

echo "==> gemini-cli/agy global memory file (GEMINI.md)"

mkdir -p "$(dirname "$TARGET")"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "${TARGET}.bak.$(date +%s)"
  echo "  (existing ~/.gemini/GEMINI.md backed up)"
fi

ln -sfnv "${DOTS_DIR}/gemini/GEMINI.md" "$TARGET"
