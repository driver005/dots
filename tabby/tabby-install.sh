#!/usr/bin/env bash
# Install Tabby (self-hosted completion + repo-index AI assistant) and start
# the packaged tabbyml.service (systemd --user, ships with the AUR package
# itself - not our own unit). Idempotent, safe to re-run.
#
# Note: `tabby` alone in pacman/AUR is a different app (Tabby/Terminus, a
# terminal emulator). The package we want is `tabbyml-bin`, and its binary
# is installed as `tabbyml`, not `tabby`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tabbyml"
CONFIG_FILE="$CONFIG_DIR/config.toml"
BIN_DIR="$HOME/.local/bin"
# Both markers must be present, not just one - otherwise a partially-applied
# render (e.g. completion set but embedding still on its packaged local
# default) would look "already configured" and never get fixed.
MARKER_COMPLETION="mistral/completion"
MARKER_EMBEDDING="voyage/embedding"

command_exists() {
  command -v "$1" &>/dev/null
}

echo "==> tabbyml-bin (via yay)"
if ! command_exists tabbyml; then
  yay -S --needed --noconfirm tabbyml-bin
fi

echo "==> nvm (Arch pacman package)"
# tabby-agent (npm CLI below) needs Node < 26 - its bundled EnvHttpProxyAgent
# (undici 6) breaks on every request under Node 26's built-in fetch (undici
# 8 internally, dispatcher interface changed - "invalid onError method").
# Known upstream issue (same root cause as nodejs/corepack#834), unfixed on
# tabby-agent's side. Rather than downgrade the system-wide `nodejs` package
# (plenty else here depends on v26), pin a separate Node 22 LTS via nvm just
# for this one tool. See tabby-agent-lts.sh, the actual launcher lsp-mode
# invokes.
if ! command_exists nvm && [ ! -s /usr/share/nvm/init-nvm.sh ]; then
  yay -S --needed --noconfirm nvm
fi
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
mkdir -p "$NVM_DIR"
[ -s /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh

echo "==> Node 22 LTS (via nvm, for tabby-agent only)"
if ! nvm ls 22 &>/dev/null; then
  nvm install 22
fi

echo "==> tabby-agent (via npm, under Node 22)"
if ! nvm exec 22 command -v tabby-agent &>/dev/null; then
  echo "  Installing tabby-agent globally under Node 22..."
  # A `prefix`/`globalconfig` in ~/.npmrc (set for the separate system-node
  # npm-global setup elsewhere in this repo) conflicts with nvm's own
  # per-version global prefix - `npm install -g` under `nvm exec` silently
  # does nothing when that's present (confirmed live: exits 0, installs
  # nothing). `nvm use --delete-prefix` is nvm's own documented fix for
  # this exact conflict, scoped to this shell only - doesn't touch
  # ~/.npmrc or the other npm-global setup.
  nvm use --delete-prefix 22 --silent
  npm install -g tabby-agent
fi

echo "==> tabby-agent-lts launcher (~/.local/bin)"
mkdir -p "$BIN_DIR"
ln -sfnv "$SCRIPT_DIR/tabby-agent-lts.sh" "$BIN_DIR/tabby-agent-lts"

echo "==> ~/.config/tabbyml/config.toml"
# Codestral is a Mistral model, so CODESTRAL_API_KEY (already set for
# Helix's lsp-ai) works here too - prefer MISTRAL_API_KEY if both are set.
[ -f "$HOME/.bashrc.secrets" ] && source "$HOME/.bashrc.secrets"
MISTRAL_API_KEY="${MISTRAL_API_KEY:-${CODESTRAL_API_KEY:-}}"

if [ -f "$CONFIG_FILE" ] && grep -q "$MARKER_COMPLETION" "$CONFIG_FILE" && grep -q "$MARKER_EMBEDDING" "$CONFIG_FILE"; then
  echo "  (already fully cloud-configured, leaving as-is)"
elif [ -z "$MISTRAL_API_KEY" ] || [ -z "${VOYAGE_API_KEY:-}" ]; then
  [ -z "$MISTRAL_API_KEY" ] && echo "  Neither MISTRAL_API_KEY nor CODESTRAL_API_KEY is set (check ~/.bashrc.secrets)."
  [ -z "${VOYAGE_API_KEY:-}" ] && echo "  VOYAGE_API_KEY is not set (check ~/.bashrc.secrets)."
  echo "  Skipping config render - tabbyml.service will fall back to its packaged"
  echo "  local-model defaults (StarCoder-1B etc.) until both are set and this re-runs."
else
  mkdir -p "$CONFIG_DIR"
  sed -e "s|{{MISTRAL_API_KEY}}|$MISTRAL_API_KEY|" \
      -e "s|{{VOYAGE_API_KEY}}|$VOYAGE_API_KEY|" \
      "$SCRIPT_DIR/config.toml.template" > "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
fi

echo "==> tabbyml.service (packaged, systemd --user)"
systemctl --user daemon-reload
systemctl --user enable --now tabbyml.service

echo "==> Waiting for server to come up..."
for _ in $(seq 1 30); do
  curl -sf -o /dev/null --max-time 2 http://localhost:8080 && break
  sleep 2
done

echo "==> Tabby account + personal access token"
CLIENT_CONFIG_DIR="$HOME/.tabby-client/agent"
CLIENT_CONFIG_FILE="$CLIENT_CONFIG_DIR/config.toml"
# 127.0.0.1, not "localhost": tabby-agent (the npm CLI, used for the lsp-mode
# integration - see plugin/ai/tabby/config.el) does its own health check via
# Node's fetch, which resolves "localhost" to ::1 first on this box. tabbyml
# only binds 0.0.0.0 (IPv4), so that health check silently failed until this
# was pinned to the literal IPv4 address.
CLIENT_ENDPOINT="http://127.0.0.1:8080"

write_client_token() {
  local token="$1"
  mkdir -p "$CLIENT_CONFIG_DIR"
  if [ -f "$CLIENT_CONFIG_FILE" ]; then
    sed -i -E 's/^#\s*\[server\]/[server]/' "$CLIENT_CONFIG_FILE"
    sed -i -E "s|^#?\s*endpoint\s*=.*|endpoint = \"$CLIENT_ENDPOINT\"|" "$CLIENT_CONFIG_FILE"
    sed -i -E "s|^#?\s*token\s*=.*|token = \"$token\"|" "$CLIENT_CONFIG_FILE"
  else
    cat > "$CLIENT_CONFIG_FILE" <<EOF
[server]
endpoint = "$CLIENT_ENDPOINT"
token = "$token"
EOF
  fi
  echo "  Wrote token to $CLIENT_CONFIG_FILE"
}

EXISTING_TOKEN=""
if [ -f "$CLIENT_CONFIG_FILE" ]; then
  EXISTING_TOKEN="$(grep -oP '(?<=^token = ")[^"]*' "$CLIENT_CONFIG_FILE" 2>/dev/null | head -1 || true)"
fi

if [ -n "$EXISTING_TOKEN" ] && curl -sf -o /dev/null --max-time 5 \
    -H "Authorization: Bearer $EXISTING_TOKEN" "$CLIENT_ENDPOINT/v1/health" 2>/dev/null; then
  echo "  (already have a working token, leaving as-is)"
else
  echo "  No admin account set up yet on this Tabby server. Choose credentials"
  echo "  for it (used for the web UI/dashboard, e.g. adding repos to index):"
  read -r -p "  Admin email: " ADMIN_EMAIL
  read -r -s -p "  Admin password: " ADMIN_PASSWORD
  echo
  REGISTER_QUERY='mutation($email:String!,$password1:String!,$password2:String!,$name:String!){register(email:$email,password1:$password1,password2:$password2,name:$name){accessToken}}'
  ACCESS_TOKEN="$(
    python3 -c "import json,sys; print(json.dumps({'query': sys.argv[1], 'variables': {'email': sys.argv[2], 'password1': sys.argv[3], 'password2': sys.argv[3], 'name': 'admin'}}))" \
      "$REGISTER_QUERY" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" \
    | curl -s -X POST http://localhost:8080/graphql -H "Content-Type: application/json" -d @- \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('data',{}).get('register',{}).get('accessToken') or '')" 2>/dev/null
  )"

  if [ -n "$ACCESS_TOKEN" ]; then
    echo "  Auto-registered admin account: $ADMIN_EMAIL"
    AUTH_TOKEN="$(
      curl -s -X POST http://localhost:8080/graphql -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"query":"{me{authToken}}"}' \
      | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['me']['authToken'])" 2>/dev/null
    )"
  else
    echo "  Auto-registration not possible (an admin account already exists on this server)."
    echo "  Open http://localhost:8080, log in or register, then find your personal"
    echo "  access token under settings."
    read -r -p "  Paste your Tabby personal access token: " AUTH_TOKEN
  fi

  if [ -n "${AUTH_TOKEN:-}" ]; then
    write_client_token "$AUTH_TOKEN"
  else
    echo "  No token available - tabby.el will show 401s until you set one manually."
  fi
fi

echo
echo "==> Done."
echo "Check status: systemctl --user status tabbyml.service"
echo "Logs:         journalctl --user -u tabbyml.service -f"
