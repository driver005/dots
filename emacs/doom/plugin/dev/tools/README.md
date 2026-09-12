# `:tools` — enabled modules

`ansible`, `direnv`, `editorconfig`, `tmux`, `tree-sitter`, and `upload` are commented out in `modules.el` and not active.

## `biblio`
Bibliography/citation management for academic writing.

No flags, no hard requirements (benefits from a PDF reader — `:tools pdf`, already enabled — and a completion framework — `vertico`, already enabled).

**No documented keybindings** in the module's README.

## `collab`
Real-time collaborative editing (shared buffers, like Google Docs).

Flags in use: none. Other flag available: `+tunnel` (Tox-protocol NAT traversal via `tuntox`, for collaborators behind different NATs — not installed since the flag isn't in use).

**No documented keybindings** in the module's README.

## `debugger`
Unified Debug Adapter Protocol (DAP) frontend via `dape`.

No flags. Requires per-language debug adapters, installed separately per the [dape project's own instructions](https://github.com/svaante/dape) — none pre-installed generically.

- `SPC o d` (`M-x +debugger/start`) — start the debugger, prompts for a debugger configuration (`<up>`/`<down>` to browse options).

## `docker`
Dockerfile/docker-compose editing plus container management from Emacs (via `docker.el`'s tablist-based UI).

Flags in use: none. Other flags available: `+lsp` (needs `docker-langserver`), `+tree-sitter` (needs Emacs 29.1+ and `:tools tree-sitter`).

Requires: `docker`, `docker-compose`, `docker-machine` binaries on PATH. `install-requirements.sh` installs `docker`+`docker-compose` if missing — it does **not** enable/start the daemon or add you to the `docker` group, do that yourself (`systemctl enable --now docker.service`, `sudo usermod -aG docker $USER`).

Container-list keybindings (tablist-mode, same across images/containers/volumes/networks lists):
| Key | Action |
|---|---|
| `?` | List actions |
| `l` | Configure listing |
| `m` / `u` / `t` / `U` | Mark / unmark / toggle marks / unmark all |
| `s` | Sort |
| `* r` | Mark items by regexp |
| `<` / `>` | Shrink / enlarge column |
| `C-c C-e` | Export to CSV |

## `ein`
Jupyter notebook support inside Emacs.

No flags. Needs a working Jupyter install — `install-requirements.sh` installs `jupyter` via `pip --user` if the binary isn't found.

**No documented keybindings** in the module's README.

## `eval (+overlay)`
Run code snippets/buffers/regions and see the result. `+overlay` shows the result as an overlay next to point instead of the minibuffer (falls back to minibuffer if the result's too large to fit).

No other flags exist for this module. No direct requirements — individual languages need their own interpreters/REPLs (see the relevant `:lang` module).

| Key | Action |
|---|---|
| `gR` / `M-r` (or `M-x +eval/buffer`) | Evaluate the whole buffer |
| `gr` (operator, evil) | Evaluate a selected region |
| `SPC c s` (`M-x +eval/buffer-or-region-in-repl`) | Send buffer/region to REPL, if one's open |
| `SPC o r` (`M-x +eval/open-repl-other-window`) | Open a REPL in a popup window |
| `SPC o R` (`M-x +eval/open-repl-same-window`) | Open a REPL in the current window |

## `lookup`
The framework behind "jump to definition/references, show docs" — backend-agnostic (LSP, ctags, dumb-jump, whatever's available per-language).

Flags in use: none. Other flags available: `+dictionary` (word definition/thesaurus lookup), `+docsets` (Dash.app docset integration, needs `sqlite3`), `+offline` (offline dictionary via `wordnet`, needs `+dictionary`), `+yandex` (adds Yandex/Yandex Images/Yandex Maps to `+lookup/online` backends).

Optional (none of these currently needed since the relevant flags are off): `ripgrep` (fallback jump-to-definition, already installed via `setup.sh`), `sqlite3` (for `+docsets`), `wordnet` (for `+dictionary`+`+offline`).

| Key | Action |
|---|---|
| `gd` (`+lookup/definition`) | Jump to definition |
| `gD` (`+lookup/references`) | List references |
| `K` (`+lookup/documentation`) | Open documentation for the symbol at point |
| `SPC /` or similar (`+lookup/online`, `+lookup/online-select`) | Search online (see the earlier discussion of this exact command) |

## `llm`
The `gptel` AI-chat infrastructure — the backbone of everything AI-related in this config (`plugin/ai/*`, outside this module's own scope but built on top of it).

No flags. README says an OpenAI API key is required *only if you use the OpenAI backend* — this config uses Gemini/Claude via the `llm` library's other backends instead (see `plugin/ai/*`), so no OpenAI key needed.

| Key | Action |
|---|---|
| `SPC o l a` (`gptel-add`) | Add text to LLM context |
| `SPC o l e` (`gptel-quick`) | Explain item/selection |
| `SPC o l f` (`gptel-add-file`) | Add file to LLM context |
| `SPC o l l` (`gptel`) | Open gptel chat buffer |
| `SPC o l s` (`gptel-send`) | Send text before point (or selection) |
| `SPC o l m` (`gptel-menu`) | Open gptel's configuration transient menu |
| `SPC o l r` (`gptel-rewrite`) | Rewrite/refactor the selected region |
| `SPC o l o` (`gptel-org-set-topic`) | Limit context to the current Org heading |
| `SPC o l O` (`gptel-org-set-properties`) | Store gptel config as Org properties |
| `M-g` (in a commit message buffer) | Generate a commit message (Doom's stock LLM binding — separate from this repo's own `magit-gptcommit` setup in this same folder, see below) |

Note: this repo's own `magit-extras.el` (also in this folder) adds `SPC g c g` → `magit-gptcommit-generate` (Gemini-backed AI commit messages) and `C-c C-g` in commit-message buffers → `magit-gptcommit-commit-accept`. `magit-todos` is also enabled there (auto-scans for TODOs in the magit status buffer).

## `lsp (+eglot)`
The LSP client framework itself. `+eglot` picks Emacs's built-in `eglot` over the heavier `lsp-mode` package.

Flags in use: `+eglot`. Other flags available: `+booster` (Emacs 29-only, speeds up LSP JSON parsing via `emacs-lsp-booster`, eglot-only), `+peek` (use `lsp-ui-peek` for lookup results instead of jumping directly).

**Currently does nothing** — no `:lang` module in this config has the `+lsp` flag enabled (only `emacs-lisp`, `markdown`, `org`, `sh` are active, and none use `+lsp`). Per-language LSP servers are a separate, per-language install — not handled generically by `install-requirements.sh`.

| Key | Action |
|---|---|
| `SPC c j` | Jump to symbol in current workspace |
| `SPC c J` | Jump to symbol in any workspace |

## `magit`
The git porcelain — widely considered the best git UI in any editor, not just Emacs.

Flags in use: none. Other flag available: `+forge` (GitHub issue/PR management from Emacs, needs a GitHub API token, Emacs 29.1+, slow first-run `emacsql-sqlite` build).

Requires: `git` (already installed via `setup.sh`).

- `SPC g g` (`M-x magit-status`) — open the status buffer.

(See `llm` section above for this repo's own `magit-gptcommit`/`magit-todos` additions layered on top of this module.)

## `make`
Run Makefile targets without leaving Emacs.

No flags. Requires `make` (already covered by `base-devel`/`build-essential` in `setup.sh`).

**No documented keybindings** in the module's README.

## `pass`
`pass` (the standard Unix password manager) integration.

Flags in use: none. Other flag available: `+auth` (lets Emacs use `pass` for `auth-source-pass` authentication lookups).

Requires: `pass`, GnuPG (already present as a base Arch dependency), and a password library. `install-requirements.sh` installs `pass` if missing.

**No documented keybindings** in the module's README.

## `pdf`
Better PDF viewing in Emacs via `pdf-tools` — continuous scroll, annotations, text search, isearch.

No flags. Requires the `epdfinfo` server binary, which `pdf-tools` builds for you on first `M-x pdf-tools-install` (needs `poppler`/`poppler-glib`, which `install-requirements.sh` installs).

**No documented keybindings** in the module's README beyond standard `pdf-view-mode` bindings (not enumerated there).

## `terraform`
Terraform HCL editing support.

Flags in use: none. Other flag available: `+lsp` (needs `terraform-ls` or `terraform-lsp`).

Requires the `terraform` binary on PATH. `install-requirements.sh` installs it via `yay` (AUR-only on Arch since HashiCorp's license change) if `yay` is present, otherwise prints manual-install instructions; on apt it always prints instructions since Terraform needs HashiCorp's third-party repo added first.

| Key (under `<localleader>`) | Action |
|---|---|
| `<localleader> i` | `terraform init` |
| `<localleader> p` | `terraform plan` |
| `<localleader> a` | `terraform apply` |
