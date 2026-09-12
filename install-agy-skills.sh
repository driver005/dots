#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# Agy / Antigravity "Everything" Skill Installer
#
# Installs:
#   1. antigravity-awesome-skills (full library)
#   2. cli-agent-skills
#      - claude-cli
#      - codex-cli
#      - antigravity-cli
#      - orchestrator-cli
#   3. obra/superpowers as a native Agy plugin
#
# Designed for Linux/macOS.
# ============================================================

REPO_ROOT="${HOME}/.gemini/antigravity-cli"
LOG_FILE="${REPO_ROOT}/skill-install.log"

mkdir -p "${REPO_ROOT}"

exec > >(tee -a "${LOG_FILE}") 2>&1

echo
echo "============================================================"
echo " Agy Global Skill Installer"
echo "============================================================"
echo

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

die() {
  echo
  echo "ERROR: $1"
  exit 1
}

run() {
  echo
  echo ">>> $*"
  "$@"
}

# ------------------------------------------------------------
# Prerequisites
# ------------------------------------------------------------

echo "[1/5] Checking prerequisites..."

command_exists node || die "Node.js is required."
command_exists npx || die "npx is required."
command_exists git || die "git is required."
command_exists agy || die "agy is required."

echo "Node: $(node --version)"
echo "npm:  $(npm --version)"
echo "Agy:  $(agy --version 2>/dev/null || echo 'version unavailable')"
echo "Git:  $(git --version)"

# ------------------------------------------------------------
# 1. Full Antigravity Awesome Skills
# ------------------------------------------------------------

echo
echo "[2/5] Installing COMPLETE antigravity-awesome-skills library..."
echo

# --agy targets Agy's global skill directory.
# --all explicitly requests the complete collection.
#
# This project currently documents:
#   npx antigravity-awesome-skills --agy
#
# --all is used here because we explicitly want everything.

run npx antigravity-awesome-skills \
  --agy \
  --all

# ------------------------------------------------------------
# 2. Portable CLI / Orchestration Skills
# ------------------------------------------------------------

echo
echo "[3/5] Installing CLI delegation + orchestration skills..."
echo

run npx skills add \
  billythekidz/cli-agent-skills \
  --skill claude-cli \
  --skill codex-cli \
  --skill antigravity-cli \
  --skill orchestrator-cli \
  --agent claude-code \
  --agent codex \
  --agent antigravity-cli \
  --global \
  --yes

# ------------------------------------------------------------
# 3. Superpowers
# ------------------------------------------------------------

echo
echo "[4/5] Installing Superpowers for Agy..."
echo

# Superpowers officially documents:
#
#   agy plugin install https://github.com/obra/superpowers
#
# Re-running the same command updates the installation.

run agy plugin install \
  https://github.com/obra/superpowers

# ------------------------------------------------------------
# 4. Verification
# ------------------------------------------------------------

echo
echo "[5/5] Verifying installation..."
echo

SKILLS_DIR="${HOME}/.gemini/antigravity-cli/skills"

if [[ -d "${SKILLS_DIR}" ]]; then
  echo "✓ Agy global skills directory exists:"
  echo "  ${SKILLS_DIR}"
else
  echo "⚠ Agy global skills directory was not found:"
  echo "  ${SKILLS_DIR}"
fi

echo
echo "Installed skill count:"

if [[ -d "${SKILLS_DIR}" ]]; then
  find "${SKILLS_DIR}" \
    -mindepth 1 \
    -maxdepth 2 \
    -type f \
    -name "SKILL.md" |
    wc -l
else
  echo "0"
fi

echo
echo "Agy plugins:"
agy plugin list || true

echo
echo "CLI agent skills:"
npx skills list 2>/dev/null || true

echo
echo "============================================================"
echo " Installation complete"
echo "============================================================"
echo
echo "Restart Agy before testing the new skills."
echo
echo "Global skills:"
echo "  ${SKILLS_DIR}"
echo
echo "Log:"
echo "  ${LOG_FILE}"
echo
