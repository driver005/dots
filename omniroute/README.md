# OmniRoute — Universal AI Gateway

[OmniRoute](https://github.com/diegosouzapw/OmniRoute) is a local, high-performance AI gateway that routes and auto-falls back requests across 350+ providers (including 90+ free tiers), with built-in token compression (RTK + Caveman) saving 15–95% tokens.

## Service & Endpoints

- **Dashboard:** [http://localhost:20128](http://localhost:20128) (Setup wizard automatically bypassed)
- **OpenAI Compatible Endpoint:** `http://localhost:20128/v1`
- **Anthropic Compatible Endpoint:** `http://localhost:20128`
- **Systemd User Service:** `systemctl --user status omniroute.service`

## Autoconfiguration & Setup Script

Run the automated setup script at any time:

```bash
./omniroute/setup-omniroute.sh
```

What it does automatically:
1. **Bypasses the Setup Wizard:** Pre-configures `setupComplete: true`, `requireLogin: false`, and `setup_wizard_dismissed: true` in SQLite database and settings so the web UI is immediately accessible without any onboarding modal.
2. **Connects Free Upstream Providers:** Automatically registers OpenCode Free (`opencode/big-pickle`), requiring zero external API keys.
3. **Generates Client API Key:** Provisions and saves an active local OmniRoute API key (`sk-...`) in `~/.omniroute/.env`.
4. **Exports Environment Variables:** Configures `~/.bashrc` and `~/.config/zshrc/.zshrc`:
   ```bash
   export OMNIROUTE_URL="http://localhost:20128/v1"
   export OPENAI_BASE_URL="http://localhost:20128/v1"
   export ANTHROPIC_BASE_URL="http://localhost:20128"
   export OMNIROUTE_API_KEY="sk-..."
   export OPENAI_API_KEY="${OPENAI_API_KEY:-$OMNIROUTE_API_KEY}"
   export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$OMNIROUTE_API_KEY}"
   ```
5. **Configures Doom Emacs (`gptel`):** Sets OmniRoute as the default `gptel-backend` with `auto` (allowing OmniRoute to decide routing autonomously) alongside direct options (`opencode/big-pickle`, `claude-sonnet-4-6`, `gemini-3.1-pro`, `gpt-4o`, `deepseek-chat`). Hot-reloads running Emacs daemons.
6. **Configures Coding CLIs:** Auto-wires Aider (`~/.aider.conf.yml`), OpenCode, and Strix to route through OmniRoute.
7. **Stacked Token Compression:** Enables `RTK + Headroom (Netflix engineer library) + Caveman + LLMLingua-2 (TinyBERT SLM)` locally in OmniRoute's compression pipeline.
8. **Default Behavioral Skills:** Deploys `caveman + i-have-adhd + no-ai-slop` across Claude Code (`~/.claude/CLAUDE.md`), OpenCode (`~/.config/opencode/AGENTS.md`), AGY / repo (`GEMINI.md`, `AGENTS.md`), and as an OmniRoute global gateway middleware hook.
9. **End-to-End Self Test:** Verifies inference with a live completion test.


## Emacs Integration (`gptel`)

OmniRoute is the **default backend** in Doom Emacs (`emacs/doom/plugin/ai/gptel/config.el`).

Keybindings (Leader `SPC o l`):
- `SPC o l l` (`gptel`): Open dedicated OmniRoute chat buffer
- `SPC o l s` (`gptel-send`): Send prompt before point or highlighted region
- `SPC o l m` (`gptel-menu`): Open interactive transient menu to change models, directives, or parameters
- `SPC o l a` (`gptel-add`): Add files or buffers to the current context
- `SPC o l r` (`gptel-rewrite`): Rewrite or refactor marked code with OmniRoute

Default model: `auto` (lets OmniRoute dynamically select and auto-fallback across connected providers).

## Supported Tools & Routing

- **Claude Code CLI (`claude`):** Auto-configured via `~/.claude/settings.json` (`env.ANTHROPIC_BASE_URL="http://localhost:20128"`), environment variables, and `omniroute setup-claude` profiles.
- **AGY CLI (`agy` / `gemini`):** Auto-configured via `~/.gemini/settings.json` (`modelProvider: "gemini"`), `GOOGLE_GEMINI_BASE_URL="http://localhost:20128"`, and `GEMINI_API_KEY`.
- **OpenCode (`opencode`):** Auto-configured via `omniroute setup-opencode` with 700+ models available under `omniroute/<model>`.
- **Aider (`aider`):** Configured via `~/.aider.conf.yml` pointing to `http://localhost:20128`.
- **Strix (`strix`):** Uses `OPENAI_BASE_URL` to route security scans through OmniRoute.
- **Doom Emacs (`gptel`):** Default backend pointing to `http://localhost:20128/v1/chat/completions` with model `auto`.


## Management Commands

```bash
# Re-run autoconfiguration & health check
./omniroute/setup-omniroute.sh

# Check systemd service status
systemctl --user status omniroute.service

# Restart service
systemctl --user restart omniroute.service

# Stream live request & routing logs
journalctl --user -u omniroute.service -f

# CLI provider and key status
omniroute status
omniroute providers list
omniroute keys list
```
