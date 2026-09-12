#!/usr/bin/env bash
# tabby-agent (the npm CLI, used for the lsp-mode integration in
# plugin/ai/tabby/config.el) needs Node < 26: its bundled EnvHttpProxyAgent
# (undici 6) is incompatible with Node 26's built-in fetch, which runs on
# undici 8 internally - every single request (health check, completions,
# telemetry) fails with "InvalidArgumentError: invalid onError method",
# confirmed via ~/.tabby-client/agent/logs/. Known upstream issue, same root
# cause as nodejs/corepack#834, no fix from tabby-agent's side yet.
#
# System `node` here is v26 (plenty else depends on it, not worth
# downgrading system-wide) - this pins tabby-agent to a separate Node 22 LTS
# installed via nvm instead. See tabby-install.sh for how that Node 22 and
# tabby-agent-under-it get installed; this script is just the launcher
# lsp-mode actually invokes (symlinked onto PATH as `tabby-agent-lts`).
# nvm.sh itself isn't `set -u`-safe (references unset vars internally) -
# source it BEFORE turning on strict mode, or `nvm` silently never gets
# defined and this falls through to whatever `tabby-agent` is on PATH
# instead (which is exactly the broken Node 26 one this script exists to
# avoid - confirmed live, that's what was actually happening).
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s /usr/share/nvm/init-nvm.sh ]; then
  # shellcheck source=/dev/null
  source /usr/share/nvm/init-nvm.sh
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
else
  echo "tabby-agent-lts: nvm not found - run tabby/tabby-install.sh first" >&2
  exit 1
fi

set -euo pipefail
# No `exec` here: `nvm` is a shell function (defined by sourcing nvm.sh
# above), not something on PATH - `exec` only replaces the process image
# with an actual executable it can find via PATH lookup, so `exec nvm ...`
# always failed with "nvm: not found" and silently fell through to
# whatever `tabby-agent` happened to be on PATH instead (the broken Node 26
# one this script exists to avoid - confirmed live, that's what was
# actually running this whole time despite this wrapper being in place).
nvm exec 22 tabby-agent "$@"
