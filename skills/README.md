# Global Agent Skills

Centralized skills for AI coding agents (`claude`, `opencode`, `codex`, `agy` / Antigravity, and Neovim `codecompanion.nvim`).

All skills live in `~/.agents/skills/` and are automatically symlinked to:
- `~/.claude/skills/` (Claude Code)
- `~/.config/opencode/skills/` (OpenCode)
- `~/.gemini/antigravity-cli/skills/` (Antigravity)

Run `./skills/install-skills.sh` to update and synchronize all skills.

---

## 🌟 Top Most Important Skills

### 1. Token Compression & Budgeting (`Caveman` Suite)
*Reduces agent prompt & output tokens by 60%–95%, keeping context fresh and sessions cheap.*

- **`caveman`**: Switches terse communication mode (`lite` / `full` / `ultra` / `off`). Strips filler words while preserving 100% technical substance.
- **`cavecrew`**: Guides spawning specialized low-token subagents (`cavecrew-investigator`, `cavecrew-builder`, `cavecrew-reviewer`).
- **`caveman-compress`**: Compresses memory files (`CLAUDE.md`, preferences, todos) to minimal token representation.
- **`caveman-explore`**: Read-only compact codebase explorer returning only dense `file:line` citations.
- **`caveman-learn`**: Diagnoses session token sinks and suggests optimizations.
- **`caveman-stats`**: Displays session token usage and lifetime savings in tokens & USD.

### 2. Engineering Discipline & Workflow (`Superpowers`)
*Strict engineering protocols to prevent hallucination, scope creep, and broken builds.*

- **`test-driven-development`**: Enforces RED-GREEN-REFACTOR cycle before writing implementation code.
- **`systematic-debugging`**: Structured 4-phase root-cause analysis before touching code on any bug.
- **`safe-refactor`**: Brackets refactoring with verification to guarantee zero behavioral regressions.
- **`surgical-patch`**: Restricts edits to the narrowest responsible layer with minimal diffs.
- **`verification-before-completion`**: Mandates running test/verification commands and confirming output before declaring tasks done.
- **`brainstorming`**: Explores intent, alternatives, and architecture before creative implementation.
- **`writing-plans` / `executing-plans`**: Multi-step implementation planning with checkpoints.

### 3. ADHD-Friendly Communication (`i-have-adhd`)
*Repository: [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)*

- **`i-have-adhd`**: Forces the agent to lead with the direct answer, eliminate walls of text, provide concrete time estimates, chunk steps with clear checkboxes, and maintain high signal-to-noise ratio. Trigger: `/i-have-adhd` or "use adhd mode".

### 4. Anti-AI Slop Editor (`no-ai-slop`)
*Repository: [petergyang/no-ai-slop](https://github.com/petergyang/no-ai-slop)*

- **`no-ai-slop`**: Removes 20+ patterns of AI slop (corporate buzzwords, generic intros, throat-clearing, redundant summaries, excessive adjectives) to produce crisp, human-sounding documentation and prose.

### 5. Document & Book Skill Synthesizer (`book-to-skill`)
*Repository: [virgiliojr94/book-to-skill](https://github.com/virgiliojr94/book-to-skill)*

- **`book-to-skill`**: Ingests technical books and papers (PDF, EPUB, DOCX, Markdown) and extracts frameworks, mental models, rules, and heuristics into structured, queryable agent skills.

### 6. Autonomous Security & Pentesting (`Strix` Suite)
*Repository: [usestrix/strix](https://github.com/usestrix/strix)*

- **`penetration-testing-with-strix`**: End-to-end automated penetration test on web applications.
- **`find-security-vulnerabilities-in-code`**: Static + dynamic code analysis targeting security flaws.
- **`fix-security-vulnerabilities-with-strix`**: Validates PoC exploits and generates verified remediation patches.
- **`owasp-top-10-testing`**: Targeted audit against injection, broken auth, SSRF, IDOR, etc.
- **`api-security-testing`**: Dedicated REST/GraphQL endpoint vulnerability scanning.
- **`ci-security-scanning-with-strix`**: Setup CI/CD automated security gates.

### 7. CLI Agent Delegation & Orchestration
*Repository: [billythekidz/cli-agent-skills](https://github.com/billythekidz/cli-agent-skills)*

- **`claude-cli`**: Delegates subtasks to Claude Code CLI in isolated sub-sessions.
- **`codex-cli`**: Delegates tasks to Codex CLI.
- **`antigravity-cli`**: Orchestrates tasks with Antigravity / Agy CLI.
- **`orchestrator-cli`**: Manages multi-agent pipelines and workflows across models.

### 8. Web Scraping & Research (`Firecrawl` Suite)
- **`firecrawl-scrape`** / **`firecrawl-crawl`**: Clean Markdown extraction from any website, bypassing anti-bot blockers.
- **`firecrawl-deep-research`**: Recursive multi-source technical research with synthesized citations.
