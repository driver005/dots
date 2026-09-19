#!/usr/bin/env bash
# SessionStart hook for default-agent-rules plugin.
#
# Forces i-have-adhd and no-ai-slop guidance into context every session -
# neither fires on its own otherwise: i-have-adhd ships with
# `disable-model-invocation: true` (manual /i-have-adhd only), and
# no-ai-slop has no hook at all, just a description-triggered skill entry.
#
# Reads the skills live from ~/.claude/skills/ (symlinks into
# ~/.agents/skills/, this machine's single source of truth for skills
# shared across Claude/OpenCode/Antigravity - see dots/skills/README.md)
# instead of bundling a copy, so an update there is picked up automatically
# with no separate step to keep this plugin in sync.

set -euo pipefail

SKILLS_DIR="${HOME}/.claude/skills"

adhd_content=$(cat "${SKILLS_DIR}/i-have-adhd/SKILL.md" 2>&1 || echo "Error reading i-have-adhd skill")
slop_content=$(cat "${SKILLS_DIR}/no-ai-slop/SKILL.md" 2>&1 || echo "Error reading no-ai-slop skill")

# Escape for JSON embedding via bash parameter substitution - one C-level
# pass per operation, same trick superpowers' own session-start hook uses.
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

adhd_escaped=$(escape_for_json "$adhd_content")
slop_escaped=$(escape_for_json "$slop_content")

session_context="<EXTREMELY_IMPORTANT>\nBelow is the full content of your 'i-have-adhd' and 'no-ai-slop' skills. Apply both to every response this session - i-have-adhd shapes structure/pacing, no-ai-slop shapes prose quality. Neither auto-invokes on its own, which is why this hook exists.\n\n--- i-have-adhd ---\n\n${adhd_escaped}\n\n--- no-ai-slop ---\n\n${slop_escaped}\n</EXTREMELY_IMPORTANT>"

# Claude Code reads hookSpecificOutput.additionalContext (nested). Same
# printf-over-heredoc note as superpowers: heredocs can hang on bash 5.3+.
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"

exit 0
