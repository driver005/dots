# `:lang` — enabled modules

Language modules currently active in `modules.el`. Everything else in that file is commented out (dozens of languages this config doesn't use).

## `emacs-lisp`
Elisp support: macro expansion, go-to-definition/references, syntax highlighting for defined/quoted symbols, replaces built-in `describe-function`/`describe-variable` with the richer `helpful` package, adds usage examples to docstrings.

No flags, no external requirements.

**No documented keybindings** — Doom's README for this module doesn't list any; it's mostly automatic (better `M-.`/`K` lookups, better `*Help*` buffers) rather than new commands. See `SPC h d M` → `emacs-lisp` for the live source if you need specifics.

## `markdown`
Markdown editing support.

Flags in use: none. Other flags available: `+lsp` (LSP hook for markdown-mode/gfm-mode, needs a language server like `marksman`), `+grip` (live GitHub-style preview, bound to `<localleader> p`), `+tree-sitter` (better highlighting/structural editing, needs `:tools tree-sitter`, rudimentary before Emacs 31).

Requires (optional, for full functionality):
- A markdown linter for `flycheck` — `markdownlint` (npm), `mdl` (gem), or general-purpose `proselint`/`textlint`.
- A markdown compiler for `markdown-preview` — one of `marked` (npm), `pandoc`, `discount`, or `multimarkdown`.
- Formatting goes through `:editor format` (already enabled) via `prettier`.

None of these are installed automatically by `install-requirements.sh` — pick whichever linter/compiler you actually want and install it yourself.

**No documented keybindings** in the module's own README beyond the `+grip` flag's `<localleader> p` (not enabled here).

## `org`
Org-mode plus Doom's own extensions: centralized attachment storage, executable code blocks, external `org-capture` workflow, presentation export, drag-and-drop media, export-to-clipboard.

Flags in use: none. Other flags available: `+dragndrop`, `+crypt` (org-crypt encryption), `+gnuplot` (plot tables, bound to `SPC m b p`), `+journal`, `+jupyter`, `+noter` (sync notes with a document, needs `:tools pdf`), `+pandoc`, `+present` (reveal.js/beamer/org-tree-slide), `+pretty` (unicode bullets, can be slow), `+roam` (org-roam v2, needs Emacs built with sqlite).

Soft requirements only used by specific features:
- LaTeX + `dvipng` for inline LaTeX previews.
- `gnuplot` binary for the `+gnuplot` flag.
- Whatever a babel code block's language needs to execute.

**No documented keybindings** in the module's own README — it defers to standard Org keybindings plus whatever `:lang org`-specific commands exist per-flag (e.g. `SPC m b p` only applies with `+gnuplot`, not currently enabled).

## `sh`
Shell scripting support (bash/zsh/fish/PowerShell).

Flags in use: none. Other flags available: `+fish` (fish script highlighting), `+lsp` (needs `bash-language-server`), `+powershell` (`.ps1`/`.psm1` highlighting).

Requires (optional):
- `shellcheck` for advanced linting.
- `bash-language-server` for LSP (with `+lsp`, not enabled).
- With `:tools debugger` (enabled): `bashdb`/`zshdb` for step-debugging shell scripts.
- With `:editor format` (enabled): `shfmt` for formatting `{posix,ba,mk}sh` scripts.

None of these optional binaries are auto-installed — add `shellcheck`/`shfmt` yourself if you want linting/formatting for shell scripts specifically.

**No documented keybindings** — provides `company-shell` completion and `flycheck` syntax checking automatically, no new bindings of its own.

## `cc` (+lsp)
C, C++, and Objective-C support.

Flags in use: `+lsp`. Other flags available: `+tree-sitter` (needs `:tools tree-sitter`, enabled).

Requires: a C/C++ compiler (`gcc`/`clang`, already present) and, for `+lsp`, `clangd` v9+ or `ccls` — `clangd` is already installed by `setup.sh` itself, not duplicated in `install-requirements.sh`.

| Key | Action |
|---|---|
| `<localleader> c t` | Display inheritance type hierarchy (upwards) |
| `<prefix> <localleader> c t` | Display inheritance type hierarchy (downwards) |

## `dart` (+flutter +lsp)
Dart support, with Flutter framework integration.

Flags in use: `+flutter`, `+lsp`. Other flags available: `+tree-sitter`.

Requires: Dart SDK on `$PATH` (Flutter's SDK bundles its own Dart, so installing Flutter alone covers both) — both `dart` and `flutter` binaries are already present on this machine. The LSP server is Dart's own bundled analysis server, no separate langserver package exists or is needed.

**No documented keybindings** in the module's own README.

## `common-lisp`
Common Lisp support via the `sly` REPL/development environment (not LSP-based — Lisps use their own protocol, `sly`/`slime`, instead).

No flags in use (has no `+lsp` — only `+tree-sitter`, needs `:tools tree-sitter`, enabled, is available).

Requires: SBCL (Steel Bank Common Lisp), **not currently installed** — this is a base toolchain requirement, not an LSP-flag dependency, so `install-requirements.sh` doesn't cover it; install `sbcl` yourself if you plan to actually write Common Lisp.

- `<localleader> '` — switch to/from the Sly REPL for the current buffer (a Sly session auto-starts when you open a `.lisp` file).

## `go` (+lsp)
Go support, via `gopls`.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

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

## `graphql` (+lsp)
GraphQL query language support.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: an LSP server for `+lsp` — `graphql-language-service-cli` (added to `install-requirements.sh`, npm global). Formatting goes through `:editor format` (enabled) via `prettier`.

**No documented keybindings** in the module's own README.

## `json` (+lsp)
JSON support.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: an LSP server for `+lsp` — `vscode-json-languageserver`, part of `vscode-langservers-extracted` (added to `install-requirements.sh`, AUR). Formatting via `:editor format` + `prettier`.

**No documented keybindings** in the module's own README.

## `java` (+lsp)
Java support (also covers `android-mode`/`groovy-mode`).

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: a Java SDK (OpenJDK — already pulled in as a dependency of `languagetool`) and, for `+lsp`, `eclipse.jdt.ls`/`jdtls` (added to `install-requirements.sh`, AUR — heavy first-run project indexing is normal).

**No documented keybindings** in the module's own README.

## `javascript` (+lsp)
JavaScript and TypeScript support.

Flags in use: `+lsp`. Other flags available: `+tree-sitter` (also required for JSX/TSX support specifically, needs Emacs 29.1+ — you're on 31.1).

Requires: Node.js + npm (already present) and, for `+lsp`, `typescript-language-server` + `typescript` itself (added to `install-requirements.sh`, npm global).

**No documented keybindings** in the module's own README.

## `lua` (+lsp)
Lua support, plus optional Fennel/Moonscript transpiler support and a REPL.

Flags in use: `+lsp`. Other flags available: `+fennel`, `+tree-sitter` (Lua-only, needs Emacs 30.1+), `+moonscript`.

Requires: Lua 5.1+ (already present) and, for `+lsp` under eglot, `lua-language-server` (added to `install-requirements.sh`, official pacman package).

**No documented keybindings** in the module's own README.

## `nim`
Nim support (code completion/syntax-checking via `nimsuggest`).

No flags (this module has none at all).

Requires: `nim` + `nimsuggest` (bundled with the Nim toolchain) — **not currently installed** on this machine and not covered by `install-requirements.sh` (base toolchain, not an LSP-flag dependency). Install via `pacman -S nim nimble` if you plan to write Nim.

**No documented keybindings** in the module's own README.

## `nix` (+lsp)
Nix language support plus Nix(OS) tooling (build/update/option-lookup).

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

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

## `python` (+lsp)
Python support.

Flags in use: `+lsp`. Other flags available: `+conda`, `+cython`, `+poetry`, `+pyenv`, `+pyright` (pin specifically to the pyright server), `+tree-sitter`, `+uv`.

Requires: an LSP server for `+lsp` — `ty` (Astral's server, the module's own recommended default, added to `install-requirements.sh`, official pacman package). Auto-format via `:editor format` uses `black` (not auto-installed).

| Key | Action |
|---|---|
| `<localleader> c c` | Compile Cython buffer (needs `+cython`, not enabled) |
| `<localleader> i i/r/s/o` | Insert missing / remove unused / sort / optimize imports |
| `<localleader> t r/a/s/v` | nosetests: rerun / all / one / module |
| `<localleader> t A/O/V` | nosetests + pdb: all / one / module |
| `<localleader> t f/k/t` | pytest: file / file-dwim / function |

## `rest`
Turns Emacs into a REST/HTTP API client (`restclient-mode`) — write requests as plain text, execute them in-buffer.

No flags in use. Other flags available: `+jq` (pipe responses through `jq` — needs the `jq` CLI, **not installed** on this machine; this is unrelated to LSP, so it isn't in `install-requirements.sh`'s LSP-server section).

No external requirements for the base module.

**No documented keybindings** in the module's own README beyond what's automatic (company completion, imenu support, `org-babel` integration via `ob-restclient`).

## `rust` (+lsp)
Rust support, with `cargo` integration.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: a Rust toolchain (`cargo`/`rustc`, already present via rustup) and, for `+lsp`, `rust-analyzer` (added to `install-requirements.sh`, official pacman package).

**No documented keybindings** in the module's own README (LSP + cargo integration is otherwise automatic).

## `solidity`
Solidity (Ethereum smart contract) support.

No flags (this module has none at all).

Requires: `solc` and/or `solium` linters (`npm install -g solc`/`solium`) — **not installed**, not covered by `install-requirements.sh` (linter choice left to you, same pattern as markdown's linter/compiler note above).

- `C-c C-g` — gas estimation for the contract.

## `web` (+lsp)
Support for HTML5, CSS/SASS/SCSS, Pug/Jade/Slim, HAML, and web frameworks (React, WordPress, Jekyll, Django, etc).

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: an LSP server for `+lsp` — `vscode-html-languageserver`/`vscode-css-languageserver`, part of the same `vscode-langservers-extracted` package added for `json +lsp` above (one AUR install covers both).

**No documented keybindings** in the module's own README.

## `yaml` (+lsp)
YAML file format support.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: an LSP server for `+lsp` — `yaml-language-server` (added to `install-requirements.sh`, npm global). Formatting via `:editor format` + `prettier`.

**No documented keybindings** in the module's own README.

## `zig` (+lsp)
Zig support, via `zls`.

Flags in use: `+lsp`. Other flags available: `+tree-sitter`.

Requires: a Zig install and, for `+lsp`, `zls` (added to `install-requirements.sh`, official pacman package).

| Key | Action |
|---|---|
| `<localleader> b` | `zig-compile` |
| `<localleader> f` | `zig-format-buffer` |
| `<localleader> r` | `zig-run` |
| `<localleader> t` | `zig-test-buffer` |
