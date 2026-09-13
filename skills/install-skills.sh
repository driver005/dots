#!/usr/bin/env bash
# ==============================================================================
# Global Agent Skills Installer & Synchronizer
#
# Installs and synchronizes essential agent skills across:
#   - Claude Code (~/.claude/skills)
#   - OpenCode (~/.config/opencode/skills)
#   - Antigravity / Agy (~/.gemini/antigravity-cli/skills)
#   - Codex & Roo (~/.agents/skills)
#
# Core Skills Included:
#   1. Token Optimization: Caveman & Cavecrew suite (60-95% token savings)
#   2. Engineering Discipline: Superpowers (TDD, Systematic Debugging, Safe Refactor)
#   3. ADHD-Friendly Output: ayghri/i-have-adhd (action-oriented, anti-tangent)
#   4. Anti-Slop Editor: petergyang/no-ai-slop (clean, human prose)
#   5. Knowledge Synthesis: virgiliojr94/book-to-skill (book PDF/EPUB -> skills)
#   6. Autonomous Security: usestrix/strix (OWASP, web pentest, code vulnerability)
#   7. CLI Delegation: billythekidz/cli-agent-skills (claude-cli, codex-cli, agy-cli)
#   8. Web Intelligence: firecrawl suite (search, crawl, scrape, research)
# ==============================================================================
set -euo pipefail

echo "============================================================"
echo " Global Agent Skills Installer"
echo "============================================================"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists npx; then
  echo "Error: npx is required to install skills." >&2
  exit 1
fi

AGENTS_SKILLS="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
OPENCODE_SKILLS="$HOME/.config/opencode/skills"
AGY_SKILLS="$HOME/.gemini/antigravity-cli/skills"

mkdir -p "$AGENTS_SKILLS" "$CLAUDE_SKILLS" "$OPENCODE_SKILLS" "$AGY_SKILLS"

install_skill_repo() {
  local repo="$1"
  local name="$2"
  echo "--> Installing / Updating skill: ${name} (${repo})..."
  npx --yes skills add "${repo}" --global --yes 2>&1 || {
    echo "    Warning: npx skills add failed for ${repo}, continuing..."
  }
}

echo
echo "[1/3] Installing Core Global Skills..."
# 1. ADHD-friendly concise output
install_skill_repo "ayghri/i-have-adhd" "i-have-adhd"

# 2. No AI Slop writer/reviewer
install_skill_repo "petergyang/no-ai-slop" "no-ai-slop"

# 3. Book to Skill converter
install_skill_repo "virgiliojr94/book-to-skill" "book-to-skill"

# 4. Strix pentesting & security skills
install_skill_repo "usestrix/strix" "strix"

# 5. CLI Agent delegation skills
install_skill_repo "billythekidz/cli-agent-skills" "cli-agent-skills"

# 6. Antigravity awesome skills (if not already installed)
if command_exists agy; then
  echo "--> Updating Agy plugins (Superpowers)..."
  agy plugin install https://github.com/obra/superpowers 2>/dev/null || true
fi

echo
echo "[2/3] Synchronizing all skills across agent directories..."
# Link every skill in ~/.agents/skills into ~/.claude/skills, ~/.config/opencode/skills, and Agy
for skill_dir in "$AGENTS_SKILLS"/*; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")

  # Link to Claude Code
  ln -sfn "$skill_dir" "$CLAUDE_SKILLS/$skill_name"

  # Link to OpenCode
  ln -sfn "$skill_dir" "$OPENCODE_SKILLS/$skill_name"

  # Link to Agy
  ln -sfn "$skill_dir" "$AGY_SKILLS/$skill_name"
done

echo "✓ Synchronized $(find "$AGENTS_SKILLS" -mindepth 1 -maxdepth 1 -type d | wc -l) skills across all agents."

echo
echo "[3/3] Active Global Skills Summary:"
echo "------------------------------------------------------------"
echo "  ~/.agents/skills:   $(find "$AGENTS_SKILLS" -mindepth 1 -maxdepth 1 -type d | wc -l) skills"
echo "  ~/.claude/skills:   $(find "$CLAUDE_SKILLS" -mindepth 1 -maxdepth 1 -type l -o -type d | wc -l) skills"
echo "  ~/.config/opencode: $(find "$OPENCODE_SKILLS" -mindepth 1 -maxdepth 1 -type l -o -type d | wc -l) skills"
echo "  Agy skills:         $(find "$AGY_SKILLS" -mindepth 1 -maxdepth 1 -type l -o -type d | wc -l) skills"
echo "------------------------------------------------------------"
echo "Skill installation complete!"
