# Helix

A Rust modal editor installed alongside the LazyVim setup. Config lives here in
`dots/helix/` and is symlinked to `~/.config/helix` (same pattern as nvim).

Helix is **selection-first**: you select *then* act (noun → verb), the opposite
of vim's verb → noun. Most things you did with LazyVim plugins are built in.

## Install

```bash
~/dots/scripts/helix-install.sh   # helix + all 17 language servers + formatters
hx --health                       # verify: theme + each server shows a green path
```

> Arch's `helix` package installs the binary as **`helix`**, not `hx`. The
> install script symlinks `/usr/local/bin/hx -> helix` (needs sudo) so the
> config, `tmux/sessions/dev.sh`, and `EDITOR=hx` all work. If `hx` is missing,
> run: `sudo ln -sf "$(command -v helix)" /usr/local/bin/hx`.

## Files

| File | Purpose |
|------|---------|
| `config.toml` | editor options, theme, keymaps, space-leader menu |
| `languages.toml` | per-language servers + format-on-save |
| `themes/catppuccin_transparent.toml` | catppuccin_mocha with transparent bg (matches nvim + tmux) |

## Keymap cheatsheet

Helix defaults you'll use most (these are **not** remapped):

| Key | Action |
|-----|--------|
| `w` `b` `e` | word motions (they *select* as they move) |
| `x` | select whole line (repeat to extend) |
| `d` / `c` / `y` | delete / change / yank the **current selection** |
| `v` | enter select (extend) mode |
| `gd` `gr` `gi` | goto definition / references / implementation |
| `gh` `gl` | line start / end |
| `space k` | hover docs |
| `space s` | symbol picker (aerial-like) |
| `space f` / `space /` | file picker / global search |
| `C-w` then `h/j/k/l` | window nav (splits) |
| `mi(` `ma"` etc. | match inside/around (built-in surround/textobjects) |
| `ms(` / `md(` / `mr("` | surround add / delete / replace |

### Vim-familiar layer added on top (see config.toml)

| Key | Action |
|-----|--------|
| `dd` `dw` `de` `db` `dj` `dk` `d$` `d0` `dgg`/`dg` `dG` | delete line / word / word-end / word-back / line+below / line+above / to-eol / to-bol / to-file-start / to-end |
| `yy` `yw` `ye` `yb` `yj` `yk` `y$` `y0` `yg` `yG` | yank (same motions) |
| `cc` `cw` `ce` `cb` `c$` `c0` | change (same motions) |
| `D` / `Y` | delete / yank to end of line |
| `{` / `}` | paragraph up / down · `%` matching bracket · `^` first non-blank |
| `*` / `#` | search word under cursor fwd / back |
| `V` | visual-line select · `S` vim-surround add (needs selection) |
| `C-s` | save |
| `G` | goto last line · `0` / `$` line start/end |
| `U` | redo |
| `jk` (insert) | escape to normal mode |

> Trade-off: making `d`/`y`/`c` prefixes means a **bare** `d` now waits for a
> second key instead of deleting the selection immediately. Use `x` then the
> Helix-native command, or `v`+motion+`d`, when you want the selection-first way.
>
> **Textobjects** (`diw`, `da(`, `ci"`) are NOT config-mappable — Helix consumes
> the textobject char before a delete can chain (config-only limitation). Use
> the Helix-native equivalents instead: `mi(` / `ma"` / `miw` select inside/
> around, then `d`/`c`/`y`. For *true* vim textobjects (`diw`, `daf`) you'd need
> the **vim.hx** patch — a forked Helix binary; see below.

### Want full vim (diw / daf / f-t-find-char)? → vim.hx

Two public projects mirror vim in Helix:

| Project | What it is | Trade-off |
|---------|-----------|-----------|
| [LGUG2Z/helix-vim](https://github.com/LGUG2Z/helix-vim) | a `config.toml` (like ours) | config-only; no true textobjects, no leader groups. We already borrowed its usable binds. |
| [badranX/vim.hx](https://github.com/badranX/vim.hx) | a **forked Helix binary** (patch) | real vim: `diw`, `da)`, `daf` (treesitter), `f`/`t`/`F`/`T`, true visual mode, `:vim-enable`/`:vim-disable`. Cost: build from source / prebuilt binary, replaces stock `helix`, tracks upstream separately. |

Our config takes the config-only path (no binary swap, stays on Arch's `helix`).
Switch to vim.hx only if you want full vim modality over Helix's selection model.

### Space leader menu (mirrors LazyVim `<leader>` groups)

Press `space` and Helix pops a hint menu (which-key-like). The leader is now
**nested** like LazyVim: `space f` opens the *find* group, `space f f` finds
files. The vim **motions** stay on the `d`/`y`/`c` operator menus above
(operator-first: `dd`/`dw`/`cw`/`yy`) — there is no motion-first menu, because
`w`/`b`/`e`/`o` must remain bare navigation keys.

**Top-level singles** (LazyVim quick-access leaders):

| `space …` | Action |
|-----------|--------|
| `space` / `,` / `/` / `:` | files / buffers / grep / command palette |
| `e` | file explorer |
| `k` / `d` | hover / diagnostics |
| `a` | **Claude Code** CLI in a tmux split |
| `t` | toggle markdown checkbox `[ ]`↔`[x]` on the current line |

**Groups** (press `space` + letter, then the member):

| Group | Members |
|-------|---------|
| `f` find | `f` files · `d` files near buffer · `r` resume · `b` buffers · `e` explorer · `n` new · `c` edit config · `s` save |
| `b` buffer | `b` switch · `d` delete · `o` delete others · `n`/`p` next/prev |
| `c` code | `a` action · `r` rename · `f` format · `d` diagnostics · `s` symbols · `h` hover |
| `s` search | `g` grep · `s`/`S` doc/workspace symbols · `d`/`D` doc/workspace diagnostics · `b` in-buffer · `j` jumplist · `r` resume · `k` commands |
| `g` git | `g` **lazygit** · `f` changed files · `b` blame (tmux) |
| `u` ui toggle | `w` wrap · `n` line-number · `i` inlay hints · `c` cursorline |
| `w` window | `v`/`s` vsplit/hsplit · `d` close · `o` close others · `w` cycle · `h`/`j`/`k`/`l` nav |
| `x` trouble | `x` doc diagnostics · `X` workspace diagnostics |
| `q` quit | `q` quit · `Q` quit all · `w` save+quit |

### Markdown snippets (scls)

Type a prefix in a markdown file and pick it from the completion popup:
`checkbox`/`cb`/`todo` → `- [ ] `, `done` → `- [x] `, `heading1`..`heading6`,
`bold`, `italic`, `strikethrough`, `code`, `codeblock`, `link`, `image`,
`quote`, `note`, `table`, `unordered`, `ordered`. Edit them in
`~/.config/helix/snippets/markdown.toml`; add other languages as
`<lang>.toml`.

## AI, three ways

| Tool | Role | Status |
|------|------|--------|
| **lsp-ai** + Codestral FIM | inline completion in the popup | **on** (cpp/c/rust/go/zig) |
| **llmvm-codeassist** | AI completion via code-actions, with LSP context | **opt-in** (see below) |
| **Claude Code** in a tmux pane | full agent, `space a` | **on** |

### llmvm-codeassist (opt-in)

`llmvm-codeassist` *wraps* the real language server (`llmvm-codeassist clangd …`):
it forwards all LSP features and adds AI completion to the **code-actions** menu
(select code → code action). It's installed by `helix-install.sh` but **not
wired**, because it replaces the LSP and needs setup:

1. Run `llmvm-codeassist` once to generate `~/.config/llmvm/codeassist.toml`.
2. Configure the `llmvm-outsource` backend with the Anthropic provider + an
   `ANTHROPIC_API_KEY` (not in your secrets yet — add it to `~/.bashrc.secrets`).
3. In `languages.toml`, uncomment the `[language-server.llmvm-codeassist-*]`
   blocks and set the language's `language-servers` to
   `["llmvm-codeassist-cpp", "lsp-ai"]` (wrapper + inline FIM).

Don't list a bare `clangd`/`rust-analyzer` *and* the wrapper for the same
language — the wrapper already launches it.

## Claude Code integration

Helix has no plugin/terminal API, so `space a` runs `tmux split-window -h claude`
— Claude Code opens in a new tmux pane beside the editor, using your existing
Claude Code login (no API key). Same idea for lazygit on `space g`.

### Why not ACP?

You asked about controlling Claude Code over the **Agent Client Protocol (ACP)**
— Zed's open "LSP-for-agents". Claude Code has ACP adapters
(`@zed-industries/claude-code-acp`), but **Helix is not an ACP client** (no
native agent support as of 2026), so it cannot drive Claude Code over ACP. ACP
clients today are **Zed, Neovim, and Emacs**. If you want real in-editor agent
control (streaming diffs, tool calls, permissions), that belongs in your
**Neovim** setup (an ACP client plugin) or Zed — not Helix. In Helix, the tmux
pane above is the practical Claude Code integration.

## What did NOT port from nvim (no Helix equivalent)

| nvim thing | Helix reality |
|------------|---------------|
| minuet / Codestral inline AI | **Ported** via `lsp-ai` + Mistral Codestral FIM (reuses `CODESTRAL_API_KEY`). Attached to cpp/c/rust/go/zig in `languages.toml`; suggestions land in the completion popup (not vim-style ghost text). Add more langs by appending `"lsp-ai"` to that language's `language-servers`. Plus Claude Code in a pane (`space a`). |
| neogit / diffview / gitsigns | No git UI; built-in diff gutter only. Use lazygit (`space g`). |
| codecompanion, mcp, vectorcode, octocode | No plugin system; external CLIs only. |
| which-key popup | Partial — Helix shows keymap hints natively after a prefix. |
| treesitter-context (sticky scroll), aerial | Symbol picker (`space s`) is the closest; no sticky context bar. |
| markdown checkbox toggle, bullets.vim | **Ported**: snippets via `scls` (`~/.config/helix/snippets/markdown.toml`); checkbox toggle on `space t` (pipes the line through `scripts/toggle-checkbox.sh`). |
| smart-splits seamless tmux nav | `C-w` inside Helix; tmux prefix to cross into tmux panes. |

## Language servers (all 17)

clangd (C/C++, incl. `.cppm`/`.ixx`) · rust-analyzer (clippy on save) · gopls ·
typescript-language-server · vscode-json/html/css · yaml-language-server ·
taplo (toml) · marksman (markdown) · zls (zig) · jdtls (java) · sqls (sql) ·
dart · cmake-language-server · docker-langserver · svelteserver ·
@vue/language-server · @tailwindcss/language-server. Formatters: clang-format,
rustfmt, gofmt, prettier (web/yaml/json/markdown), stylua, shfmt, taplo.
