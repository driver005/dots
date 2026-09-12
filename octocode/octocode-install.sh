#!/usr/bin/env bash
# Install octocode (structural codebase graph + semantic search for AI
# agents, used via the mcp.el/gptel-mcp.el Doom integration under
# SPC o l g) and symlink its config into place. Idempotent, safe to re-run.
#
# Note: `octocode` alone in pacman/AUR tends to lag behind upstream - built
# from source via cargo instead, matching how it was already installed here.
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/octocode"
CONFIG_FILE="$CONFIG_DIR/config.toml"

command_exists() {
  command -v "$1" &>/dev/null
}

echo "==> octocode (via cargo)"
if ! command_exists octocode; then
  cargo install --git https://github.com/Muvon/octocode --features huggingface --force
fi

echo "==> ~/.local/share/octocode/config.toml"
# Uses FastEmbed (genuine local ONNX, no API key, no network calls) for
# both code and text embeddings - the HuggingFace-hub-routed default this
# ships with was measured taking 100x+ longer (a 55-file repo took over an
# hour and still hadn't finished, vs ~40s with FastEmbed).
mkdir -p "$CONFIG_DIR"
ln -sfnv "$DOTS_DIR/octocode/config.toml" "$CONFIG_FILE"

echo
echo "==> Done."
echo "Verify: octocode config --show"
