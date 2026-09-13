#!/usr/bin/env bash
# Install Emacs + Chemacs2, then register Doom Emacs and Spacemacs as
# switchable Chemacs2 profiles. Idempotent: safe to re-run (clones are
# skipped if the target dir already exists; existing profiles.el is left
# alone unless it doesn't exist yet).
set -euo pipefail

echo "==> Emacs"
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
  if command -v emacs &>/dev/null && ! emacs --batch --eval '(princ system-configuration-features)' 2>/dev/null | grep -q 'PGTK'; then
    echo "  Found Emacs without Wayland (PGTK) support. Uninstalling..."
    sudo pacman -Rdd --noconfirm emacs || true
  fi
  sudo pacman -S --needed --noconfirm emacs-wayland
else
  sudo pacman -S --needed --noconfirm emacs
fi

CHEMACS_DIR="$HOME/.emacs.d"
PROFILES_FILE="$HOME/.emacs-profiles.el"
DOOM_DIR="$HOME/.emacs.doom.d"
SPACEMACS_DIR="$HOME/.emacs.spacemacs.d"

echo "==> Chemacs2 (profile switcher)"
if [ -e "$CHEMACS_DIR" ] && [ ! -e "$CHEMACS_DIR/chemacs.el" ]; then
  mv "$CHEMACS_DIR" "$CHEMACS_DIR.bak.$(date +%s)"
fi
if [ ! -e "$CHEMACS_DIR" ]; then
  git clone --depth 1 https://github.com/plexus/chemacs2 "$CHEMACS_DIR"
else
  git -C "$CHEMACS_DIR" pull --ff-only
fi

echo "==> Doom Emacs (profile: doom)"
if [ ! -e "$DOOM_DIR" ]; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$DOOM_DIR"
else
  git -C "$DOOM_DIR" pull --ff-only
fi

echo "==> Spacemacs (profile: spacemacs)"
if [ ! -e "$SPACEMACS_DIR" ]; then
  git clone --depth 1 https://github.com/syl20bnr/spacemacs "$SPACEMACS_DIR"
else
  git -C "$SPACEMACS_DIR" pull --ff-only
fi

echo "==> ~/.emacs-profiles.el"
if [ ! -e "$PROFILES_FILE" ]; then
  cat > "$PROFILES_FILE" <<EOF
(("doom" . ((user-emacs-directory . "$DOOM_DIR")))
 ("spacemacs" . ((user-emacs-directory . "$SPACEMACS_DIR")))
 ("default" . ((user-emacs-directory . "$DOOM_DIR"))))
EOF
else
  echo "  (already exists, leaving as-is)"
fi

echo "==> config symlinks (~/.config/{doom,spacemacs} -> ../dots/emacs/*)"
# Configs live in dots/emacs/{doom,spacemacs} (git-tracked), same pattern as
# nvim/helix. Not `stow doom`/`stow spacemacs` here: bare stow drops a
# package's contents straight into the stow target (~/.config), it only
# nests under a package-name subdir when invoked as `stow .` from the repo
# root - and that whole-repo restow conflicts with pre-existing unmanaged
# files under tmux/helix. Plain symlinks sidestep that safely, matching how
# nvim/alacritty already sit.
for name in doom spacemacs; do
  if [ -e "$HOME/.config/$name" ] && [ ! -L "$HOME/.config/$name" ]; then
    mv "$HOME/.config/$name" "$HOME/.config/$name.bak.$(date +%s)"
  fi
  ln -sfnv "$PWD/emacs/$name" "$HOME/.config/$name"
done

echo "==> spell/grammar checkers requirements (aspell, LanguageTool)"
"$(dirname "${BASH_SOURCE[0]}")/install-requirements.sh"

echo "==> link tree-sitter grammars from Helix runtime"
mkdir -p "$DOOM_DIR/.local/etc/tree-sitter"
if [ -d "$PWD/helix/runtime/grammars" ]; then
  for grammar in "$PWD"/helix/runtime/grammars/*.so; do
    [ -e "$grammar" ] || continue
    lang=$(basename "$grammar" .so)
    ln -sf "$grammar" "$DOOM_DIR/.local/etc/tree-sitter/libtree-sitter-${lang}.so"
  done
fi

echo "==> doom install (--force suppresses prompts, safe to re-run)"
DOOMDIR="$HOME/.config/doom" "$DOOM_DIR/bin/doom" install --force --env --install

echo "==> doom build (compile packages for speed)"
DOOMDIR="$HOME/.config/doom" "$DOOM_DIR/bin/doom" build || true

echo "==> AOT Native Compilation (Wait for hardware acceleration to finish)"
# This tells Emacs to compile everything to C machine code and wait until it's done.
# It prevents the background async workers from spawning later when you open Emacs.
emacs --batch -Q --eval "(when (fboundp 'native-compile-async)
  (require 'comp-run)
  (message \"Starting blocking AOT native compilation...\")
  (native-compile-async \"$DOOM_DIR/.local/straight/\" t)
  (while (or (and (boundp 'comp-async-compilations) (> (hash-table-count comp-async-compilations) 0))
             (and (boundp 'comp-files-queue) comp-files-queue))
    (message \"Files left to compile: %s\" (if (boundp 'comp-async-compilations)
                                               (hash-table-count comp-async-compilations)
                                             (length comp-files-queue)))
    (sleep-for 2)))"

echo "==> enable and restart Emacs daemon (instant startup)"
systemctl --user enable emacs || true
systemctl --user restart emacs || true

echo "==> shorthand aliases (doom, spacemacs, dm)"
# alias -f overwrites so ours always wins over the doom CLI or anything else
# on PATH claiming these names; only ~/.emacs.doom.d/bin is left off PATH.
# SPACEMACSDIR is set explicitly (not relying on XDG_CONFIG_HOME, which this
# system doesn't export) so Spacemacs picks up ~/.config/spacemacs instead
# of generating a fresh ~/.spacemacs.d/init.el.
ALIAS_MARKER="# emacs-install.sh: doom/spacemacs profile shorthands"
ALIAS_BLOCK="$ALIAS_MARKER
alias doom='emacs --with-profile doom'
alias spacemacs='SPACEMACSDIR=\$HOME/.config/spacemacs emacs --with-profile spacemacs'
alias dm='emacsclient -c -a \"emacs\"'"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -e "$rc" ]; then
    if ! grep -qF "$ALIAS_MARKER" "$rc"; then
      printf '\n%s\n' "$ALIAS_BLOCK" >> "$rc"
    else
      echo "  (already in $rc, leaving as-is)"
    fi
  fi
done

echo
echo "==> Done."
echo "Spacemacs bootstraps itself on first launch: emacs --with-profile spacemacs"
echo
echo "Switch profiles with: doom | spacemacs (aliases, after a new shell) or emacs --with-profile <name>"
echo "Run ./scripts/dotfiles-update.sh to install the pacman hook that keeps"
echo "LazyVim/Helix/tmux/Doom/Spacemacs updated automatically on garuda-update."
