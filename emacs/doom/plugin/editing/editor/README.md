# `:editor` — enabled modules

`god`, `lispy`, `objed`, `parinfer` are commented out — see the earlier discussion of why (Lisp-specific or non-evil alternatives, redundant given evil's already active).

## `evil (+everywhere)`
Vim editing model for all of Emacs. `+everywhere` pulls in `evil-collection` to evilify packages without native evil support (magit, dired, etc).

No other flags exist. No external requirements.

Evil text objects (used as `i`/`a` + these letters, e.g. `ci"`, `daf`):
| Object | Selects |
|---|---|
| `w` / `W` | words |
| `s` | sentences |
| `p` | paragraphs |
| `b` / `( ) { } [ ] < >` | parenthesized/bracket blocks |
| `' " \`` | quotes |
| `t` | tags |
| `o` | symbols |
| `a` | C-style function arguments |
| `B` | any brace/paren/bracket-delimited block |
| `c` | comments |
| `f` | functions (needs sane major-mode definitions) |
| `g` | entire buffer |
| `i` / `j` / `k` | by indentation |
| `q` | quotes (any kind) |
| `u` | URLs |
| `x` | XML attributes |

Vim-plugin-equivalents baked in: `gc` (comment, vim-commentary), `gs` (easymotion), `gl`/`gL` (align, vim-lion), `s`/`S`/`z`/`Z`/`x`/`X` (snipe/sneak), `S`(visual)/`ys` (surround). Visual mode `*`/`#` search for the current selection.

## `file-templates`
Auto-inserts a yasnippet template into new empty files based on filename.

No flags, no external requirements.

- Type a snippet's trigger + `TAB` to expand a template (works like any yasnippet trigger).
- `<help> f set-file-template!` — look up how to write your own.

## `fold`
Universal code folding (hideshow + vimish-fold + outline).

No flags, no external requirements.

| Key | Action |
|---|---|
| `C-c C-f C-f` | Fold region |
| `C-c C-f C-u` or `` C-` `` | Unfold region |
| `C-c C-f C-d` | Delete folded region |
| `C-c C-f C-a C-f` | Fold all regions |
| `C-c C-f C-a C-u` | Unfold all regions |
| `C-c C-a C-d` | Delete all folded regions |

If a region won't re-fold, delete the folded region first (`C-c C-f C-d`), then fold again.

## `format (+onsave +lsp)`
Auto-formats code on save via `apheleia`. `+onsave` is what makes it automatic — without it you'd invoke formatting manually.

Flags in use: `+onsave`, `+lsp` (dispatches formatting to the active LSP client when available, falling back to local CLI formatters).

No direct requirements — each language needs its own formatter binary on PATH (apheleia fails silently if missing).

- `SPC u SPC f s` (evil) / `C-u C-x C-s` (non-evil) — save with a universal argument, skipping format-on-save just this once.

## `multiple-cursors`
Sublime/Atom-style multi-cursor editing (via `evil-mc` + `iedit`).

No flags, no external requirements.

| Key | Action |
|---|---|
| `gzz` | Toggle a (frozen) cursor at point |
| `gzt` | Toggle mirroring on/off |
| `gzA` / `gzI` | Place cursors at end / start of each selected line |
| `M-d` | iedit the symbol at point (repeat to match next occurrence) |
| `M-S-d` | Same, backwards |
| `R` (visual mode) | iedit all matches of the current selection |

## `rotate-text`
Cycle a keyword/text pattern at point through a candidate set (`true`↔`false`, `public`↔`private`↔`protected`, etc).

No flags, no external requirements.

- `]r` / `[r` (evil) — cycle forward / backward through candidates at point.

## `snippets`
The `yasnippet` engine itself (backs `file-templates` above).

No flags, no external requirements. No keybindings of its own beyond trigger+`TAB` expansion (see `file-templates`).

## `whitespace (+guess +trim)`
Background whitespace housekeeping, no keybindings.

- `+guess` — auto-detects tabs-vs-spaces/indent-width per file to match its existing convention.
- `+trim` — strips trailing whitespace on save, only in regions touched this session.

No other flags exist. No external requirements.

## `word-wrap`
Soft-wraps long lines at word boundaries, indentation-aware, without modifying buffer content.

No flags, no external requirements.

- `SPC t w` — toggle `+word-wrap-mode`.

---

## Repo-custom additions (`config.el` in this folder, not Doom-stock)

From `crux`:
| Key | Action |
|---|---|
| `C-a` | `crux-move-beginning-of-line` |
| `C-k` | `crux-smart-kill-line` |
| `M-o` | `crux-smart-open-line` |
| `C-c d` | `crux-duplicate-current-line-or-region` |
| `C-c D` | `crux-delete-file-and-buffer` |
| `C-c r` | `crux-rename-file-and-buffer` |

From `string-inflection`: `C-c i` — `string-inflection-all-cycle` (cycle naming convention: `snake_case`→`camelCase`→`PascalCase`→...).

From `visual-regexp`(+steroids): `C-c q` — `vr/query-replace` (regex query-replace with live preview).

From `ialign`: `M-x ialign` — interactive column alignment.

From this repo directly (not a package, plain `map!`):
| Key | Action |
|---|---|
| `[j` | `evil-jump-backward` (jumplist back — same as `C-o`, extra mnemonic entry matching this module's own `[r`/`]r` bracket-motion convention) |
| `]j` | `evil-jump-forward` (jumplist forward — same as `C-i`) |
