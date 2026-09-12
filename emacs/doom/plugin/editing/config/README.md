# `:config` — enabled modules

`literate` is commented out — this repo writes plain `.el` files directly rather than tangling from a `config.org`.

## `default (+bindings +smartparens)`
Doom's "reasonable defaults" bundle: a Spacemacs-inspired `SPC`-leader keybinding scheme, repeat-search on `;`/`,`, `avy` jump-to-char, `drag-stuff` (move lines/regions), `link-hint`.

Flags in use:
- `+bindings` — the entire `SPC`-leader keybinding layer. Everything discussed this session under `SPC h d M`, `SPC r r`/`rt`/`rp`/`rf`/`re`/`rd` (reload variants), `SPC b b`/`bi`/`bm`/`bt`/`bf`/`bk` (bindings-help variants), `SPC O` (`+lookup/online`) lives behind this flag — without it, evil still works but none of Doom's own leader shortcuts exist.
- `+smartparens` — context-aware auto-pairing of delimiters per major-mode (`/*` → `*/` in C, `<?php` → `?>` in PHP, `def` → `end` in Ruby, etc.), not just blind bracket-matching.

Other flag available: `+gnupg` (GnuPG key/pinentry-emacs integration — not enabled here).

No external requirements. No repo-custom additions in this folder — everything here is Doom-stock.
