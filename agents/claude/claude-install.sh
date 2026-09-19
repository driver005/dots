#!/usr/bin/env bash
# Register the default-agent-rules Claude Code plugin (dots/claude/default-agent-rules)
# in ~/.claude/settings.json - auto-loads i-have-adhd + no-ai-slop skill
# guidance every session via a SessionStart hook (see the plugin's own
# plugin.json for why: neither skill fires on its own otherwise).
#
# Idempotent: merges into ~/.claude/settings.json rather than overwriting it
# (that file carries hooks, MCP servers, and other plugin registrations that
# must survive a re-run), and is a no-op if already registered.
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${DOTS_DIR}/claude/default-agent-rules"
SETTINGS_FILE="${HOME}/.claude/settings.json"

echo "==> default-agent-rules Claude Code plugin"

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required to merge ~/.claude/settings.json." >&2
  exit 1
fi

mkdir -p "$(dirname "$SETTINGS_FILE")"
[ -e "$SETTINGS_FILE" ] || echo '{}' > "$SETTINGS_FILE"

PLUGIN_DIR="$PLUGIN_DIR" SETTINGS_FILE="$SETTINGS_FILE" python3 <<'PYEOF'
import json
import os

settings_file = os.environ["SETTINGS_FILE"]
plugin_dir = os.environ["PLUGIN_DIR"]

with open(settings_file) as f:
    settings = json.load(f)

marketplaces = settings.setdefault("extraKnownMarketplaces", {})
marketplaces["default-agent-rules"] = {
    "source": {"source": "directory", "path": plugin_dir}
}

plugins = settings.setdefault("enabledPlugins", {})
changed = plugins.get("default-agent-rules@default-agent-rules") is not True
plugins["default-agent-rules@default-agent-rules"] = True

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("  registered" if changed else "  (already registered, path refreshed)")
PYEOF

if command -v claude &>/dev/null; then
  claude plugin validate "$PLUGIN_DIR"
fi

echo "  Restart Claude Code (or open /hooks once) to activate it in running sessions."
