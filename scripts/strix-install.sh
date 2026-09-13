#!/usr/bin/env bash
# ==============================================================================
# Strix Installer - Open-source AI Autonomous Penetration Testing Tool
# https://github.com/usestrix/strix
#
# Installs:
#   1. Strix CLI binary (~/.strix/bin/strix, symlinked to ~/.local/bin/strix)
#   2. Strix Agent Skills (9 skills for OWASP, web pentesting, code audit, etc.)
# ==============================================================================
set -euo pipefail

echo "============================================================"
echo " Strix Installation & Setup"
echo "============================================================"

# Helper function
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure destination directory exists
mkdir -p "$HOME/.local/bin"

echo "[1/3] Installing Strix CLI binary..."
if command_exists strix; then
  echo "Strix is already installed at $(command -v strix): $(strix --version 2>/dev/null || echo 'unknown version')"
  echo "Running installer to ensure it's up to date..."
fi

curl -sSL https://strix.ai/install | bash || true

# Ensure symlink in ~/.local/bin
if [ -f "$HOME/.strix/bin/strix" ]; then
  ln -sf "$HOME/.strix/bin/strix" "$HOME/.local/bin/strix"
  echo "✓ Symlinked ~/.strix/bin/strix -> ~/.local/bin/strix"
fi

echo
echo "[2/3] Installing Strix Agent Skills (via npx skills)..."
if command_exists npx; then
  npx --yes skills add usestrix/strix --global --yes || true
else
  echo "npx not found; skipping agent skills installation."
fi

echo
echo "[3/3] Docker Requirement Check..."
if command_exists docker; then
  if docker info >/dev/null 2>&1; then
    echo "✓ Docker daemon is running."
    echo "Pulling Strix sandbox image (ghcr.io/usestrix/strix-sandbox:1.3.0)..."
    docker pull ghcr.io/usestrix/strix-sandbox:1.3.0 || true
  else
    echo "Note: Docker is installed but daemon is not running."
    echo "Start Docker when you are ready to run scans: sudo systemctl start docker"
  fi
else
  echo "Note: Docker is required to run scans with Strix."
  echo "Install docker with: sudo pacman -S docker && sudo systemctl enable --now docker"
fi

echo
echo "============================================================"
echo " Strix installation complete!"
echo " Binary: $(command -v strix 2>/dev/null || echo "$HOME/.local/bin/strix")"
echo " Usage:  strix --target ./my-app"
echo "============================================================"
