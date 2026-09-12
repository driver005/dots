# `:checkers` — enabled modules

All three checkers modules are active.

## `syntax`
Syntax/error checking via `flycheck` (or `flymake`, if `+flymake` flag is used — not here).

Flags in use: none. Other flags available: `+childframe` (errors in a GUI child frame instead of overlay/tooltip, GUI Emacs only), `+flymake` (use built-in `flymake` instead of `flycheck`), `+icons` (unicode icons instead of ASCII prefixes).

No direct requirements — individual `:lang` checkers may need their own linters (run `doom doctor` to check).

| Key | Action |
|---|---|
| `C-c ! ?` | Describe checker |
| `C-c ! c` | Check syntax in buffer |
| `C-c ! l` / `SPC c x` | List errors |
| `C-c ! n` / `] e` | Next error |
| `C-c ! p` / `[ e` | Previous error |
| `C-c ! C` | Clear all errors in buffer |
| `C-c ! e` | Explain error at point |
| `C-c ! h` | Display all errors at point |
| `SPC t f` | Toggle flycheck |

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
