# `:checkers` — enabled modules

All three checkers modules are active.

## `syntax (+flymake)`
Asynchronous syntax and error checking via Emacs's native `flymake` engine.

Flags in use: `+flymake` (replaces heavy `flycheck` with Emacs 31's built-in asynchronous `flymake` engine, eliminating background process timer stutters and cooperating directly with LSP diagnostics).

Other flags available: `+childframe`, `+icons`.

No direct requirements — syntax checking hooks directly into active LSP servers and built-in compilers.

| Key | Action |
|---|---|
| `] e` / `[ e` | Next / previous error |
| `SPC c x` | List buffer diagnostics / errors |
| `SPC t f` | Toggle syntax checking |

## `spell (+flyspell)`
Spell-checking. `+flyspell` uses the `flyspell` backend instead of the faster-but-more-limited `spell-fu` (slower, but supports multiple languages/dictionaries at once).

Other flags available: `+aspell`/`+hunspell`/`+enchant` (choose the correction backend — defaults to whatever's on PATH if unset), `+everywhere` (spell-check comments in programming modes too, not just prose).

Requires `aspell` + `aspell-en` (or `hunspell`/`enchant-2`) — `install-requirements.sh` installs `aspell`+`aspell-en`.

- `zg` (evil) — mark word at point as correct (add to personal dictionary).
- `zw` (evil) — mark word at point as incorrect.

## `grammar`
Grammar/style checking, combining LanguageTool (`langtool`) + `writegood-mode`.

No flags. Requires LanguageTool (Java 1.8+) — `install-requirements.sh` installs it.

| Key | Action |
|---|---|
| `M-x langtool-check` | Run LanguageTool grammar check on the buffer |
| `M-x langtool-correct-buffer` | Interactively apply LanguageTool's suggested corrections |
| `<localleader> g` (writegood-mode) | `writegood-grade-level` — Flesch-Kincaid grade level |
| `<localleader> r` (writegood-mode) | `writegood-reading-ease` |

writegood-mode itself (highlighting weasel words/passive voice/duplicate words) is a minor mode — toggle it manually when writing prose; it isn't auto-enabled everywhere.
