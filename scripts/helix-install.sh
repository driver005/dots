#!/usr/bin/env bash
# Install Helix + language servers + formatters for all 17 languages that the
# nvim/LazyVim config enables, then wire the config symlink and treesitter
# grammars. Idempotent: safe to re-run. Uses --needed / --noconfirm so it does
# not re-fetch what is already present.
set -euo pipefail

echo "==> Helix editor"
sudo pacman -S --needed --noconfirm helix

echo "==> Language servers + formatters (official repos)"
# gopls(go), taplo(toml), marksman(markdown), zls(zig), sqls(sql),
# dart(bundles analysis server), shfmt/stylua/prettier(formatters),
# clang(clangd+clang-format) and rust-analyzer/rustfmt are assumed present.
sudo pacman -S --needed --noconfirm \
  gopls taplo marksman zls sqls dart \
  shfmt stylua prettier \
  yaml-language-server

echo "==> AUR packages (jdtls for java)"
paru -S --needed --noconfirm jdtls || echo "  (skip jdtls if it fails - java optional)"

echo "==> npm-based servers (web stack + docker + json/html/css)"
sudo npm install -g \
  vscode-langservers-extracted \
  dockerfile-language-server-nodejs \
  typescript typescript-language-server \
  svelte-language-server \
  @vue/language-server \
  @tailwindcss/language-server

echo "==> cmake-language-server (pipx)"
pipx install cmake-language-server 2>/dev/null || pip install --user cmake-language-server || true

echo "==> lsp-ai (AI completion via Mistral Codestral FIM)"
# Uses CODESTRAL_API_KEY from ~/.bashrc.secrets. Attached to cpp/c/rust/go/zig
# in languages.toml; suggestions appear in Helix's completion popup.
cargo install lsp-ai --locked || echo "  (lsp-ai install failed - AI completion optional)"

echo "==> llmvm-codeassist (OPT-IN: LSP-wrapping AI code-actions, Anthropic/Claude)"
# Installed but NOT wired in languages.toml by default - it wraps (replaces)
# the real LSP and needs the llmvm daemon + a backend/API key configured at
# ~/.config/llmvm/codeassist.toml. See HELIX.md "llmvm-codeassist" to enable.
cargo install llmvm-codeassist llmvm-core llmvm-outsource || \
  echo "  (llmvm install failed - optional)"

echo "==> simple-completion-language-server (snippets + word completion)"
# Serves ~/.config/helix/snippets/*.toml (markdown checkbox/heading/etc.) and
# buffer-word/path completion. Wired to markdown in languages.toml.
cargo install simple-completion-language-server || \
  echo "  (scls install failed - snippets optional)"

echo "==> config symlink (~/.config/helix -> ../dots/helix)"
if [ -e "$HOME/.config/helix" ] && [ ! -L "$HOME/.config/helix" ]; then
  mv "$HOME/.config/helix" "$HOME/.config/helix.bak.$(date +%s)"
fi
ln -sfn ../dots/helix "$HOME/.config/helix"

echo "==> hx symlink (Arch's helix package ships the binary as 'helix', not 'hx')"
# The config, tmux/sessions/dev.sh and EDITOR=hx all call 'hx'. Point it at the
# real binary so muscle memory + non-interactive spawns work. Idempotent.
if ! command -v hx >/dev/null 2>&1; then
  HELIX_BIN="$(command -v helix || echo /usr/bin/helix)"
  sudo ln -sf "$HELIX_BIN" /usr/local/bin/hx
fi

echo "==> treesitter grammars"
hx --grammar fetch
hx --grammar build

echo
echo "==> Done. Run 'hx --health' to verify servers are detected."
