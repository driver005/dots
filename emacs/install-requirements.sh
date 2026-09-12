#!/usr/bin/env bash
# Install the system-level requirements for every currently-enabled Doom
# module (across plugin/{editing,dev,extras}/*/modules.el) that needs one.
# Idempotent, safe to re-run. Pure-elisp modules with zero external deps
# (most :editor/:ui/:completion modules, :tools llm/eval,
# :emacs electric/ibuffer/tramp/undo/vc, :app calendar) need nothing here -
# only modules with a real binary/library dependency get a block below.
#
# NOT handled here (deliberately, see comments at each skip):
# - clangd for :lang cc +lsp - already installed by setup.sh itself.
# - dart/flutter's own analysis server for :lang dart +lsp - bundled with
#   the Dart/Flutter SDK (already present on this machine), no separate
#   langserver package exists to install.
# - :lang common-lisp and :lang rest have no +lsp flag (SLY/SLIME and +jq
#   are their respective non-LSP alternatives) - nothing to install here.
# - ghostel's native module - self-installs on first `M-x ghostel`.
# - notmuch's mail *sync* config (~/.mbsyncrc etc) - only the binaries.
# - Google Calendar OAuth for :app calendar - user-side setup, no package.
set -euo pipefail

command_exists() {
  command -v "$1" &>/dev/null
}

if command_exists pacman; then
  PKG_INSTALL="sudo pacman -S --noconfirm --needed"
  PM=pacman
elif command_exists apt; then
  PKG_INSTALL="sudo apt install -y"
  PM=apt
else
  echo "Error: No supported package manager found (apt or pacman)." >&2
  exit 1
fi

# aspell (+ English dictionary): backs :checkers spell (flyspell).
if ! command_exists aspell; then
  echo "==> aspell + aspell-en"
  $PKG_INSTALL aspell aspell-en
fi

# enchant + hunspell + German dictionary: backs :checkers spell's +enchant
# flag. enchant is just a meta-backend - it needs an actual dictionary
# engine underneath, and aspell-en alone only covers English. hunspell-de
# adds German (this repo's spell module has +everywhere too, for comments
# in code, so this covers prose and code alike in both languages).
if ! command_exists enchant-2; then
  echo "==> enchant (:checkers spell +enchant)"
  $PKG_INSTALL enchant
fi
if ! command_exists hunspell; then
  echo "==> hunspell (dictionary engine for enchant)"
  $PKG_INSTALL hunspell
fi
if [ "$PM" = pacman ]; then
  if ! pacman -Qq hunspell-de &>/dev/null; then
    echo "==> hunspell-de (German dictionary)"
    $PKG_INSTALL hunspell-de
  fi
else
  echo "Note: install a German hunspell dictionary manually on apt, e.g. 'hunspell-de-de'."
fi

# nuspell, hspell, libvoikko: on Arch, the `enchant' package itself ships
# .so shims for ALL its backends (aspell, hunspell, hspell, nuspell,
# voikko) unconditionally - not just the ones you actually installed. The
# missing ones fail to dlopen at broker startup and print warnings to
# stderr, which `ispell-init-process' treats as a hard failure, so
# flyspell-mode silently refuses to enable even though aspell/hunspell
# themselves work fine. Installing these (no dictionary data needed, just
# satisfies the linker) is what actually fixes it, not a cosmetic nicety.
if [ "$PM" = pacman ] && command_exists enchant-2; then
  if ! pacman -Qq nuspell hspell libvoikko &>/dev/null; then
    echo "==> nuspell + hspell + libvoikko (silence enchant broker warnings that break flyspell)"
    $PKG_INSTALL nuspell hspell libvoikko
  fi
fi

# LanguageTool: backs :checkers grammar (langtool + writegood-mode). Needs
# Java 1.8+, which the languagetool package pulls in as a dependency.
if ! command_exists languagetool && ! command_exists languagetool-commandline; then
  echo "==> languagetool"
  $PKG_INSTALL languagetool
fi

# ttf-nerd-fonts-symbols-mono: the actual glyph font `nerd-icons.el' renders
# from - backs every `+icons' flag used this session (dired, ibuffer, corfu,
# vertico) plus :ui treemacs's unconditional nerd-icons theme. Having a
# patched code font like FiraCode Nerd Font is NOT enough on its own - that
# only patches a handful of glyphs into the code font, it's not the full
# icon set nerd-icons.el expects. On apt, use `M-x nerd-icons-install-fonts'
# instead (no equivalent distro package).
if ! fc-list 2>/dev/null | grep -qi "Symbols Nerd Font Mono"; then
  if [ "$PM" = pacman ]; then
    echo "==> ttf-nerd-fonts-symbols-mono (icon glyphs for all +icons flags)"
    $PKG_INSTALL ttf-nerd-fonts-symbols-mono
    fc-cache -f &>/dev/null || true
  else
    echo "No 'Symbols Nerd Font Mono' found and no apt package for it."
    echo "  Run 'M-x nerd-icons-install-fonts' inside Emacs instead."
  fi
fi

# poppler(-glib): backs :emacs dired's PDF preview (pdftoppm/pdftocairo,
# from `poppler') and :tools pdf's epdfinfo build (needs poppler-glib
# headers). Debian splits the dev headers into their own -dev package.
if ! command_exists pdftoppm; then
  echo "==> poppler (PDF preview/build support for dired + :tools pdf)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL poppler poppler-glib
  else
    $PKG_INSTALL poppler-utils libpoppler-glib-dev
  fi
fi

# imagemagick, ffmpegthumbnailer, mediainfo, tar, unzip: optional but
# recommended by :emacs dired's own README for image/video/audio previews
# and archive-file previews in dired buffers.
if ! command_exists identify; then
  echo "==> imagemagick (dired image previews)"
  $PKG_INSTALL imagemagick
fi
if ! command_exists ffmpegthumbnailer; then
  echo "==> ffmpegthumbnailer (dired video previews)"
  $PKG_INSTALL ffmpegthumbnailer
fi
if ! command_exists mediainfo; then
  echo "==> mediainfo (dired audio/video metadata)"
  $PKG_INSTALL mediainfo
fi
for bin_pkg in "tar:tar" "unzip:unzip"; do
  bin="${bin_pkg%%:*}"; pkg="${bin_pkg##*:}"
  if ! command_exists "$bin"; then
    echo "==> $pkg (dired archive previews)"
    $PKG_INSTALL "$pkg"
  fi
done

# pass + a password library: backs :tools pass.
if ! command_exists pass; then
  echo "==> pass (:tools pass)"
  $PKG_INSTALL pass
fi

# docker + docker-compose: backs :tools docker. Doesn't start/enable the
# daemon or add your user to the docker group - do that yourself
# (systemctl enable --now docker.service; sudo usermod -aG docker $USER).
if ! command_exists docker; then
  echo "==> docker + docker-compose (:tools docker)"
  $PKG_INSTALL docker docker-compose
fi

# terraform: backs :tools terraform. Not in Arch's official repos anymore
# (license change) - needs an AUR helper. Not auto-installed on apt since
# it needs HashiCorp's third-party repo added first; see
# https://developer.hashicorp.com/terraform/install#linux
if [ "$PM" = pacman ] && ! command_exists terraform; then
  if command_exists yay; then
    echo "==> terraform (AUR, via yay) (:tools terraform)"
    yay -S --needed --noconfirm terraform
  else
    echo "Skipping terraform: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists terraform; then
  echo "Skipping terraform: needs HashiCorp's apt repo added first, see:"
  echo "  https://developer.hashicorp.com/terraform/install#linux"
fi

# terraform-lsp: backs :tools terraform's +lsp flag (langserver, separate
# from the terraform CLI itself). AUR-only on Arch, same as terraform.
if [ "$PM" = pacman ] && ! command_exists terraform-lsp; then
  if command_exists yay; then
    echo "==> terraform-lsp (AUR, via yay) (:tools terraform +lsp)"
    yay -S --needed --noconfirm terraform-lsp
  else
    echo "Skipping terraform-lsp: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists terraform-lsp; then
  echo "Skipping terraform-lsp: no apt package, see https://github.com/juliosueiras/terraform-lsp"
fi

# emacs-lsp-booster: backs :tools lsp's +booster flag (JSON->bytecode speedup
# for eglot). AUR-only. If you ever edit over TRAMP, this also needs to be
# installed on the remote host, which this script can't do for you.
if [ "$PM" = pacman ] && ! command_exists emacs-lsp-booster; then
  if command_exists yay; then
    echo "==> emacs-lsp-booster (AUR, via yay) (:tools lsp +booster)"
    yay -S --needed --noconfirm emacs-lsp-booster
  else
    echo "Skipping emacs-lsp-booster: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists emacs-lsp-booster; then
  echo "Skipping emacs-lsp-booster: no apt package, see https://github.com/blahgeek/emacs-lsp-booster"
fi

# jupyter: backs :tools ein (Jupyter notebooks in Emacs).
if ! command_exists jupyter; then
  echo "==> jupyter (:tools ein)"
  python3 -m pip install --user jupyter 2>/dev/null || \
    python3 -m pip install --user --break-system-packages jupyter
fi

# xclip, xdotool, xprop, xwininfo: backs :app everywhere (emacs-everywhere,
# capture-a-popup-anywhere-on-the-desktop). These are X11 tools; on Wayland
# (this system is GNOME/Wayland) they still work for XWayland-backed
# windows via XWayland's compatibility layer, but a native-Wayland target
# window may not be controllable - that's an upstream emacs-everywhere
# limitation, not something this script can work around.
if ! command_exists xdotool; then
  echo "==> xclip, xdotool, xprop, xwininfo (:app everywhere)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL xclip xdotool xorg-xprop xorg-xwininfo
  else
    $PKG_INSTALL xclip xdotool x11-utils
  fi
fi

# notmuch + isync (mbsync): backs :email notmuch. isync/mbsync is the
# actual mail *sync* tool (downloads mail into a local Maildir); notmuch
# only indexes/tags what's already there. Writing the ~/.mbsyncrc account
# config itself is out of scope here - that's credential-specific.
if ! command_exists notmuch; then
  echo "==> notmuch + isync (:email notmuch)"
  $PKG_INSTALL notmuch isync
fi

# --- :lang language servers (each backs that language's +lsp flag) ---

# gopls: backs :lang go +lsp. Official pacman package.
if ! command_exists gopls; then
  echo "==> gopls (:lang go +lsp)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL gopls
  else
    echo "Skipping gopls: no apt package, install via 'go install golang.org/x/tools/gopls@latest' (needs Go)."
  fi
fi

# rust-analyzer: backs :lang rust +lsp. Official pacman package.
if ! command_exists rust-analyzer; then
  echo "==> rust-analyzer (:lang rust +lsp)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL rust-analyzer
  else
    $PKG_INSTALL rust-analyzer || echo "Skipping rust-analyzer: install via rustup if not packaged."
  fi
fi

# lua-language-server: backs :lang lua +lsp. Official pacman package.
if ! command_exists lua-language-server; then
  echo "==> lua-language-server (:lang lua +lsp)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL lua-language-server
  else
    echo "Skipping lua-language-server: no apt package, see https://github.com/LuaLS/lua-language-server/releases"
  fi
fi

# zls: backs :lang zig +lsp. Official pacman package.
if ! command_exists zls; then
  echo "==> zls (:lang zig +lsp)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL zls
  else
    echo "Skipping zls: no apt package, see https://github.com/zigtools/zls#installation"
  fi
fi

# ty: backs :lang python +lsp. Astral's LSP/type-checker, the doom+ python
# module's own recommended server. Official pacman package.
if ! command_exists ty; then
  echo "==> ty (:lang python +lsp)"
  if [ "$PM" = pacman ]; then
    $PKG_INSTALL ty
  else
    python3 -m pip install --user ty 2>/dev/null || \
      python3 -m pip install --user --break-system-packages ty
  fi
fi

# typescript-language-server (+ typescript itself): backs :lang javascript
# +lsp. npm global install, same on both distros.
if ! command_exists typescript-language-server; then
  echo "==> typescript-language-server + typescript (:lang javascript +lsp)"
  sudo npm install -g typescript typescript-language-server
fi

# graphql-language-service-cli: backs :lang graphql +lsp. npm global.
if ! command_exists graphql-lsp; then
  echo "==> graphql-language-service-cli (:lang graphql +lsp)"
  sudo npm install -g graphql-language-service-cli
fi

# yaml-language-server: backs :lang yaml +lsp. npm global.
if ! command_exists yaml-language-server; then
  echo "==> yaml-language-server (:lang yaml +lsp)"
  sudo npm install -g yaml-language-server
fi

# purescript-language-server: backs :lang purescript +lsp. npm global. Does
# NOT install the PureScript compiler/toolchain itself (spago/purs) - that's
# a separate, opinionated choice (spago vs plain purs) left to you.
if ! command_exists purescript-language-server; then
  echo "==> purescript-language-server (:lang purescript +lsp)"
  sudo npm install -g purescript-language-server
fi

# vscode-langservers-extracted: backs :lang json +lsp and :lang web +lsp
# (bundles the json/html/css/eslint servers VSCode ships). AUR-only on Arch.
if [ "$PM" = pacman ] && ! command_exists vscode-json-language-server; then
  if command_exists yay; then
    echo "==> vscode-langservers-extracted (AUR, via yay) (:lang json/web +lsp)"
    yay -S --needed --noconfirm vscode-langservers-extracted
  else
    echo "Skipping vscode-langservers-extracted: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists vscode-json-language-server; then
  echo "==> vscode-langservers-extracted (npm) (:lang json/web +lsp)"
  sudo npm install -g vscode-langservers-extracted
fi

# jdtls: backs :lang java +lsp (eclipse.jdt.ls). AUR-only on Arch, heavy
# first-run indexing is normal.
if [ "$PM" = pacman ] && ! command_exists jdtls; then
  if command_exists yay; then
    echo "==> jdtls (AUR, via yay) (:lang java +lsp)"
    yay -S --needed --noconfirm jdtls
  else
    echo "Skipping jdtls: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists jdtls; then
  echo "Skipping jdtls: no apt package, see https://github.com/eclipse-jdtls/eclipse.jdt.ls"
fi

# nil: backs :lang nix +lsp. Normally installed via the Nix package manager
# itself (`nix profile install nixpkgs#nil`), which isn't present on this
# system - no Arch/Debian package was found for it either. Skipping; install
# manually if you set up Nix, or use rnix-lsp as the module's alternative.
if ! command_exists nil && ! command_exists rnix-lsp; then
  echo "Skipping nil/rnix-lsp (:lang nix +lsp): no Nix package manager and no distro package found."
  echo "  Install manually, e.g. via a Nix install, or see https://github.com/oxalica/nil"
fi

# bazel + buildifier: not a Doom :lang module at all (added manually via
# plugin/dev/lang/packages.el, the `bazel' MELPA package). bazelisk (a
# bazel-version-launcher wrapper) was already present on this machine;
# buildifier (BUILD/WORKSPACE/*.bzl formatter, used on save) is AUR-only.
if ! command_exists bazel && ! command_exists bazelisk; then
  echo "==> bazel"
  $PKG_INSTALL bazel
fi
if [ "$PM" = pacman ] && ! command_exists buildifier; then
  if command_exists yay; then
    echo "==> buildifier (AUR, via yay)"
    yay -S --needed --noconfirm buildifier-bin
  else
    echo "Skipping buildifier: no yay found, and it's AUR-only on Arch. Install manually."
  fi
elif [ "$PM" = apt ] && ! command_exists buildifier; then
  echo "Skipping buildifier: no apt package, see https://github.com/bazelbuild/buildtools/releases"
fi
