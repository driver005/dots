#!/usr/bin/env bash
# ==============================================================================
# OmniRoute AI Gateway Installer & Setup
# https://github.com/diegosouzapw/OmniRoute
#
# Sets up OmniRoute as a background systemd user service on port 20128,
# and configures global routing variables so all AI tools flow through it:
#   - Dashboard: http://localhost:20128
#   - OpenAI API: http://localhost:20128/v1
#   - Anthropic API: http://localhost:20128
# ==============================================================================
set -euo pipefail

echo "============================================================"
echo " OmniRoute AI Gateway Installation & Setup"
echo "============================================================"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

NPM_GLOBAL_BIN="$HOME/.npm-global/bin"
export PATH="$NPM_GLOBAL_BIN:$PATH"

echo "[1/4] Installing OmniRoute CLI & Gateway..."
if ! command_exists omniroute; then
  echo "Installing omniroute via npm into ~/.npm-global..."
  npm install -g --prefix "$HOME/.npm-global" omniroute
else
  echo "✓ OmniRoute is already installed: $(command -v omniroute)"
fi

echo
echo "[2/4] Setting up systemd user service..."
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"
cp -f "$(dirname "${BASH_SOURCE[0]}")/omniroute.service" "$SERVICE_DIR/omniroute.service"

systemctl --user daemon-reload
systemctl --user enable --now omniroute.service || {
  echo "Warning: could not start systemctl user service automatically (running outside systemd session?)."
  echo "Run manually: omniroute &"
}

echo
echo "[3/4] Configuring AI environment variables..."
ENV_LINE_OPENAI='export OPENAI_BASE_URL="http://localhost:20128/v1"'
ENV_LINE_ANTHROPIC='export ANTHROPIC_BASE_URL="http://localhost:20128"'
ENV_LINE_OMNIROUTE='export OMNIROUTE_URL="http://localhost:20128/v1"'

# Add to ~/.bashrc if not present
if ! grep -q "OMNIROUTE_URL" "$HOME/.bashrc" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.bashrc"

# OmniRoute AI Gateway (http://localhost:20128)
export OMNIROUTE_URL="http://localhost:20128/v1"
export OPENAI_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_BASE_URL="http://localhost:20128"
EOF
  echo "✓ Added OmniRoute environment variables to ~/.bashrc"
fi

# Add to zshrc if present
if [ -f "$HOME/.config/zshrc/.zshrc" ] && ! grep -q "OMNIROUTE_URL" "$HOME/.config/zshrc/.zshrc" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.config/zshrc/.zshrc"

# OmniRoute AI Gateway (http://localhost:20128)
export OMNIROUTE_URL="http://localhost:20128/v1"
export OPENAI_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_BASE_URL="http://localhost:20128"
EOF
  echo "✓ Added OmniRoute environment variables to ~/.config/zshrc/.zshrc"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo
echo "[4/4] Running autoconfiguration (wizard bypass, free providers, Emacs integration)..."
"$SCRIPT_DIR/setup-omniroute.sh"

echo
echo "============================================================"
echo " OmniRoute installation & autoconfiguration complete!"
echo " Dashboard: http://localhost:20128"
echo " API Base:  http://localhost:20128/v1"
echo " Service:   systemctl --user status omniroute.service"
echo "============================================================"
