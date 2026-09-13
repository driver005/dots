# `:lang` — enabled modules

Language modules currently active in `modules.el`. Everything else in that file is commented out (dozens of languages this config doesn't use).

## `emacs-lisp`
Elisp support: macro expansion, go-to-definition/references, syntax highlighting for defined/quoted symbols, replaces built-in `describe-function`/`describe-variable` with the richer `helpful` package, adds usage examples to docstrings.

No flags, no external requirements.

**No documented keybindings** — Doom's README for this module doesn't list any; it's mostly automatic (better `M-.`/`K` lookups, better `*Help*` buffers) rather than new commands. See `SPC h d M` → `emacs-lisp` for the live source if you need specifics.

## `markdown` (+lsp +tree-sitter)
Markdown editing support.

Flags in use: `+lsp` (LSP integration via `marksman`), `+tree-sitter` (uses Emacs 31's native `markdown-ts-mode` with tree-sitter grammars for high-performance syntax highlighting, eliminating regex backtracking and `redisplay_internal` lag). Other flags available: `+grip` (live GitHub-style preview, bound to `<localleader> p`).

Requires:
- A markdown compiler for `markdown-preview` — `marked` is installed and managed via `install-requirements.sh`.
- Formatting goes through `:editor format` (already enabled) via `prettier`.

Preview in Doom:
- `markdown-preview` is configured to preview **inside Doom** via Emacs's EWW viewer in a right-hand vertical split (taking 50% width).
- In the preview window, pressing `q` or `ESC` immediately closes the split and restores full editor focus.

| Key | Action |
|---|---|
| `<localleader> p` (`SPC m p`) | Preview in Doom (opens side-by-side rendered view in EWW) |
| `<localleader> P` (`SPC m P`) | Toggle live preview in Doom (auto-updates on save) |
| `<localleader> o` (`SPC m o`) | Open compiled preview in external desktop browser (`xdg-open`) |
| `<localleader> t m` (`SPC m t m`) | Toggle inline markup hiding (hides `**`, `*`, `#` for reading) |
| `<localleader> t i` (`SPC m t i`) | Toggle inline image rendering |

## `org` (+dragndrop +noter +roam +journal +crypt)
Org-mode plus Doom's own extensions: centralized attachment storage, executable code blocks, external `org-capture` workflow, presentation export, drag-and-drop media, export-to-clipboard.

Flags in use:
- `+dragndrop`: Drag-and-drop images and attachments into org buffers with inline preview (`org-download`).
- `+noter`: Synchronized note-taking alongside PDF/ePub documents (pairs with `:tools pdf`).
- `+roam`: Networked notes / Zettelkasten knowledge graph (`org-roam` v2 with SQLite backend).
- `+journal`: Daily logs and diary entries (`org-journal`, `<localleader> j` / `SPC n j`).
- `+crypt`: GPG encryption/decryption for sensitive subtrees (`org-crypt`).

Other flags available: `+gnuplot`, `+jupyter`, `+pandoc`, `+present`, `+pretty` (avoided for performance).

Soft requirements only used by specific features:
- LaTeX + `dvipng` for inline LaTeX previews.
- GnuPG for `+crypt` (already present on system).
- SQLite for `+roam` (built into Emacs 31).

**Keybindings:**
- `<localleader> m` / `SPC m` — Org menu and subsystem dispatch.
- `SPC n r` — `org-roam` commands (`find-node`, `insert-node`, `capture`).
- `SPC n j` — `org-journal` commands (`new-entry`, `search`).

## `sh` (+lsp)
Shell scripting support (bash/zsh/fish/PowerShell).

Flags in use: `+lsp` (needs `bash-language-server`). Other flags available: `+fish` (fish script highlighting), `+powershell` (`.ps1`/`.psm1` highlighting).

Requires (optional):
- `shellcheck` for advanced linting.
- `bash-language-server` for LSP (with `+lsp`).
- With `:tools debugger` (enabled): `bashdb`/`zshdb` for step-debugging shell scripts.
- With `:editor format` (enabled): `shfmt` for formatting `{posix,ba,mk}sh` scripts.

None of these optional binaries are auto-installed — add `shellcheck`/`shfmt` yourself if you want linting/formatting for shell scripts specifically.

**No documented keybindings** — provides `flycheck` syntax checking and LSP diagnostics/completion automatically.

## `cc` (+lsp +tree-sitter)
C, C++, and Objective-C support.

Flags in use: `+lsp`, `+tree-sitter` (uses `c-ts-mode`, `c++-ts-mode`, `cmake-ts-mode`).

Requires: a C/C++ compiler (`gcc`/`clang`, already present) and, for `+lsp`, `clangd` v9+ or `ccls` — `clangd` is already installed by `setup.sh` itself, not duplicated in `install-requirements.sh`.

| Key | Action |
|---|---|
| `<localleader> c t` | Display inheritance type hierarchy (upwards) |
| `<prefix> <localleader> c t` | Display inheritance type hierarchy (downwards) |

## `dart` (+flutter +lsp +tree-sitter)
Dart support, with Flutter framework integration.

Flags in use: `+flutter`, `+lsp`, `+tree-sitter` (uses `dart-ts-mode`).

Requires: Dart SDK on `$PATH` (Flutter's SDK bundles its own Dart, so installing Flutter alone covers both) — both `dart` and `flutter` binaries are already present on this machine. The LSP server is Dart's own bundled analysis server, no separate langserver package exists or is needed.

**No documented keybindings** in the module's own README.

## `common-lisp` (+tree-sitter)
Common Lisp support via the `sly` REPL/development environment (not LSP-based — Lisps use their own protocol, `sly`/`slime`, instead).

Flags in use: `+tree-sitter` (uses `lisp-ts-mode`).

Requires: SBCL (Steel Bank Common Lisp), **not currently installed** — this is a base toolchain requirement, not an LSP-flag dependency, so `install-requirements.sh` doesn't cover it; install `sbcl` yourself if you plan to actually write Common Lisp.

- `<localleader> '` — switch to/from the Sly REPL for the current buffer (a Sly session auto-starts when you open a `.lisp` file).

## `go` (+lsp +tree-sitter)
Go support, via `gopls`.

Flags in use: `+lsp`, `+tree-sitter` (uses `go-ts-mode`, `go-mod-ts-mode`).

Requires: Go toolchain (already present) and `gopls` (added to `install-requirements.sh`, official pacman package).

| Key | Action |
|---|---|
| `<localleader> a` | Add field tags to a struct |
| `<localleader> d` | Remove field tags from a struct |
| `<localleader> e` | Evaluate buffer/selection in the Go playground |
| `<localleader> i` | Go to imports |
| `<localleader> b c/b/r` | `go clean` / `go build` / `go run .` |
| `<localleader> h .` | Look up symbol at point in godoc |
| `<localleader> t t/a/f/s` | Rerun last / all / file / single test |
| `<localleader> t g/G/e` | Generate tests (selected/all/exported functions) |

## `graphql` (+lsp +tree-sitter)
GraphQL query language support.

Flags in use: `+lsp`, `+tree-sitter` (uses `graphql-ts-mode`).

Requires: an LSP server for `+lsp` — `graphql-language-service-cli` (added to `install-requirements.sh`, npm global). Formatting goes through `:editor format` (enabled) via `prettier`.

**No documented keybindings** in the module's own README.

## `json` (+lsp +tree-sitter)
JSON support.

Flags in use: `+lsp`, `+tree-sitter` (uses `json-ts-mode`).

Requires: an LSP server for `+lsp` — `vscode-json-languageserver`, part of `vscode-langservers-extracted` (added to `install-requirements.sh`, AUR). Formatting via `:editor format` + `prettier`.

**No documented keybindings** in the module's own README.

## `java` (+lsp +tree-sitter)
Java support (also covers `android-mode`/`groovy-mode`).

Flags in use: `+lsp`, `+tree-sitter` (uses `java-ts-mode`).

Requires: a Java SDK (OpenJDK — already pulled in as a dependency of `languagetool`) and, for `+lsp`, `eclipse.jdt.ls`/`jdtls` (added to `install-requirements.sh`, AUR — heavy first-run project indexing is normal).

**No documented keybindings** in the module's own README.

## `javascript` (+lsp +tree-sitter)
JavaScript and TypeScript support.

Flags in use: `+lsp`, `+tree-sitter` (uses `js-ts-mode`, `typescript-ts-mode`, `tsx-ts-mode`).

Requires: Node.js + npm (already present) and, for `+lsp`, `typescript-language-server` + `typescript` itself (added to `install-requirements.sh`, npm global).

**No documented keybindings** in the module's own README.

## `lua` (+lsp +tree-sitter)
Lua support, plus optional Fennel/Moonscript transpiler support and a REPL.

Flags in use: `+lsp`, `+tree-sitter` (uses `lua-ts-mode`). Other flags available: `+fennel`, `+moonscript`.

Requires: Lua 5.1+ (already present) and, for `+lsp` under eglot, `lua-language-server` (added to `install-requirements.sh`, official pacman package).

**No documented keybindings** in the module's own README.

## `nim`
Nim support (code completion/syntax-checking via `nimsuggest`).

No flags (this module has none at all).

Requires: `nim` + `nimsuggest` (bundled with the Nim toolchain) — **not currently installed** on this machine and not covered by `install-requirements.sh` (base toolchain, not an LSP-flag dependency). Install via `pacman -S nim nimble` if you plan to write Nim.

**No documented keybindings** in the module's own README.

## `nix` (+lsp +tree-sitter)
Nix language support plus Nix(OS) tooling (build/update/option-lookup).

Flags in use: `+lsp`, `+tree-sitter` (uses `nix-ts-mode`).

Requires: an LSP server for `+lsp` — `nil` or `rnix-lsp`. **Not installed**: no Nix package manager is present on this machine and neither server has an Arch/Debian distro package, so `install-requirements.sh` only prints a skip notice here — install manually (typically via Nix itself) if you set up NixOS/Nix tooling.

| Key | Action |
|---|---|
| `<localleader> b` | `nix-build` |
| `<localleader> f` | `nix-update-fetch` |
| `<localleader> o` | Look up a Nix option |
| `<localleader> p` | `nix-format-buffer` |
| `<localleader> r` | `nix-repl-show` |
| `<localleader> s` | `nix-repl-shell` |
| `<localleader> u` | `nix-unpack` |

## `purescript` (+lsp)
PureScript support.

Flags in use: `+lsp`.

Requires: the PureScript compiler toolchain (`npm install -g purescript spago` — **not installed**, a base-toolchain choice left to you, not auto-installed) and, for `+lsp`, `purescript-language-server` (added to `install-requirements.sh`, npm global — does not include the compiler itself).

**No documented keybindings** in the module's own README.

## `python` (+lsp +tree-sitter +uv +cython)
Python support.

Flags in use:
- `+lsp`: LSP integration for diagnostics, navigation, and completion.
- `+tree-sitter`: High-performance structural parsing via `python-ts-mode`.
- `+uv`: Astral `uv` integration via `uvenv` — automatically detects and activates virtualenvs created by `uv`.
- `+cython`: Support for Cython (`.pyx`) files via `cython-mode`.

Other flags available: `+conda`, `+poetry`, `+pyenv`, `+pyright`.

Requires: an LSP server for `+lsp` — `ty` (Astral's server, the module's own recommended default, added to `install-requirements.sh`, official pacman package). Auto-format via `:editor format` uses `black` (not auto-installed).

| Key | Action |
|---|---|
| `<localleader> c c` | Compile Cython buffer (enabled with `+cython`) |
| `<localleader> i i/r/s/o` | Insert missing / remove unused / sort / optimize imports |
| `<localleader> t r/a/s/v` | nosetests: rerun / all / one / module |
| `<localleader> t A/O/V` | nosetests + pdb: all / one / module |
| `<localleader> t f/k/t` | pytest: file / file-dwim / function |

## `rest`
Turns Emacs into a REST/HTTP API client (`restclient-mode`) — write requests as plain text, execute them in-buffer.

No flags in use. Other flags available: `+jq` (pipe responses through `jq` — needs the `jq` CLI, **not installed** on this machine; this is unrelated to LSP, so it isn't in `install-requirements.sh`'s LSP-server section).

No external requirements for the base module.

**No documented keybindings** in the module's own README beyond what's automatic (company completion, imenu support, `org-babel` integration via `ob-restclient`).

## `rust` (+lsp +tree-sitter)
Rust support, with `cargo` integration.

Flags in use: `+lsp`, `+tree-sitter` (uses `rustic-mode` with tree-sitter syntax highlighting).

Requires: a Rust toolchain (`cargo`/`rustc`, already present via rustup) and, for `+lsp`, `rust-analyzer` (added to `install-requirements.sh`, official pacman package).

**No documented keybindings** in the module's own README (LSP + cargo integration is otherwise automatic).

## `solidity`
Solidity (Ethereum smart contract) support.

No flags (this module has none at all).

Requires: `solc` and/or `solium` linters (`npm install -g solc`/`solium`) — **not installed**, not covered by `install-requirements.sh` (linter choice left to you, same pattern as markdown's linter/compiler note above).

- `C-c C-g` — gas estimation for the contract.

## `web` (+lsp +tree-sitter)
Support for HTML5, CSS/SASS/SCSS, Pug/Jade/Slim, HAML, and web frameworks (React, WordPress, Jekyll, Django, etc).

Flags in use: `+lsp`, `+tree-sitter` (uses `html-ts-mode`, `css-ts-mode`).

Requires: an LSP server for `+lsp` — `vscode-html-languageserver`/`vscode-css-languageserver`, part of the same `vscode-langservers-extracted` package added for `json +lsp` above (one AUR install covers both).

**No documented keybindings** in the module's own README.

## `yaml` (+lsp +tree-sitter)
YAML file format support.

Flags in use: `+lsp`, `+tree-sitter` (uses `yaml-ts-mode`).

Requires: an LSP server for `+lsp` — `yaml-language-server` (added to `install-requirements.sh`, npm global). Formatting via `:editor format` + `prettier`.

**No documented keybindings** in the module's own README.

## `zig` (+lsp +tree-sitter)
Zig support, via `zls`.

Flags in use: `+lsp`, `+tree-sitter` (uses `zig-ts-mode`).

Requires: a Zig install and, for `+lsp`, `zls` (added to `install-requirements.sh`, official pacman package).

| Key | Action |
|---|---|
| `<localleader> b` | `zig-compile` |
| `<localleader> f` | `zig-format-buffer` |
| `<localleader> r` | `zig-run` |
| `<localleader> t` | `zig-test-buffer` |
