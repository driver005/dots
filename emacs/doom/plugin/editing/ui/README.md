# `:ui` — enabled modules

`deft`, `doom-quit`, `indent-guides`, `ligatures`, `minimap`, `nav-flash`, `neotree`, `smooth-scroll`, `tabs`, `unicode`, `window-select` are commented out.

## `doom`
Core visual theme engine (fonts, colors, `doom-themes`, split/border styling) — "what makes Doom look like Doom."

No flags, no external requirements, no keybindings — pure styling.

## `dashboard`
The startup splash screen (recent files, projects, shortcuts) shown when Emacs opens with no file argument.

No flags. Requires `nerd-icons`' fonts (installed automatically by `doom install`; run `M-x nerd-icons-install-fonts` if icons look broken).

No dedicated keybindings — it's a static buffer, shortcuts on it are just links.

## `emoji (+unicode)`
Emoji rendering/picker support.

Flags in use: `+unicode` (render native unicode emoji glyphs). Dropped `+github` and `+ascii` to eliminate background regex scanning overhead (`emojify-update-visible-emojis-background-after-command`).

Requires Emacs compiled with PNG support (standard) — ImageMagick recommended for resizing (already installed via `install-requirements.sh` for dired previews, so covered).

No dedicated keybindings documented.

## `hl-todo`
Highlights `TODO`/`FIXME`/`NOTE`/`DEPRECATED`/`HACK`/`REVIEW` comment keywords in a distinct color.

No flags, no external requirements.

| Key | Action |
|---|---|
| `]t` / `[t` | Next / previous TODO-style item |
| `SPC s p` | Search project for a string |
| `SPC s b` | Search buffer for a string |

## `modeline (+light)`
Doom's lightweight native modeline, dropping the `doom-modeline` package dependency to eliminate post-command hook churn and redisplay lag.

Flags in use: `+light`.

No external requirements, no dedicated keybindings.

## `ophints`
Briefly highlights the region an operation just acted on (e.g. after yank/delete).

No flags, no external requirements, no keybindings — purely visual feedback, automatic.

## `popup (+defaults)`
Manages transient/temporary windows (compile output, help buffers, REPLs) so they don't randomly split your layout. `+defaults` is Doom's pre-tuned ruleset.

Other flag available: `+all` (treat every buffer whose name starts with a space or `*` as a popup too — broader net, not enabled here).

No external requirements.

- `ESC` or `C-g` — dismiss a popup.
- `SPC h f set-popup-rule!` — look up how to write your own popup placement rules.

## `tabs` *(disabled)*
Previously enabled `centaur-tabs`. Disabled to eliminate redisplay lag and headerline recalculation overhead across buffer/window switches. Use `workspaces` or buffer switching (`SPC ,` / `SPC b b`) instead.

## `treemacs` (+lsp)
Sidebar project file-tree (VSCode-Explorer/NERDTree-style).

Flags in use: `+lsp` (adds `lsp-treemacs` integration: symbols view, error list, references, and workspace diagnostics).

Uses `python3` if present on PATH to show git status per-file (optional, not a hard requirement).

| Key | Action |
|---|---|
| `SPC o p` | Open the project sidebar |
| `o s` | Open a horizontal dired buffer on the highlighted node |
| `o v` | Open a vertical dired buffer on the highlighted node |

## `vc-gutter (+pretty)`
Live git-diff markers in the left fringe. `+pretty` uses thinner/smoother fringe bars (VSCode/Sublime-style) — note this looks bad with themes that invert diff-hl's foreground/background (not an issue with `doom-one`, the theme in use here).

No other flags exist. Requires any of Git/Svn/Hg/Bazaar (Git is what's installed) + the GNU variant of `diff` (standard on Linux).

No dedicated keybindings — purely visual, though the underlying `diff-hl`/git-gutter functions are reachable via `M-x` if needed.

## `vi-tilde-fringe`
Puts `~` marks in the fringe past end-of-buffer, matching Vim's behavior.

No flags, no external requirements, no keybindings — purely visual.

## `workspaces`
Tab-like persistent workspaces, each with its own buffer set.

No flags, no external requirements.

| Key | Action |
|---|---|
| `SPC TAB n` | New blank workspace |
| `SPC TAB TAB` | Display open workspaces in the mode-line |
| `SPC TAB l` / `s` | Load / save a workspace |
| `SPC TAB R` | Restore last session |
| `SPC TAB r` | Rename current workspace |
| `SPC TAB .` | Switch to an open workspace (picker) |
| `` SPC TAB ` `` | Switch to last workspace |
| `SPC TAB [` / `[ w` / `gT` | Previous workspace |
| `SPC TAB ]` / `] w` / `gt` | Next workspace |
| `SPC TAB d` | Delete current workspace |
| `SPC TAB x` / `:sclear` | Clear current session (kills all windows/buffers) |
| `M-N` | New frame (`make-frame`) |

## `zen (+focus)`
Distraction-free writing/coding mode.

Flags in use: `+focus` (dims everything but the current block/sentence; includes LSP-aware dimming if `:tools lsp` without eglot — not applicable here since this config uses `+eglot`).

No external requirements.

| Key | Action |
|---|---|
| `SPC t z` (`+zen/toggle`) | Toggle `writeroom-mode` (centered, distraction-free) |
| `SPC t Z` (`+zen/toggle-fullscreen`) | Toggle zen mode + fullscreen together |

---

## Repo-custom additions (this folder's own `.el` files, not Doom-stock)

From `theme.el`:
- Sets `doom-theme` to `doom-one`, absolute line numbers (`display-line-numbers-type` = `t`), frame starts undecorated + fullscreen on launch (`default-frame-alist`). No keybindings — startup-time settings only.

From `rainbow.el` (deliberately toggle-only, not auto-hooked, nested under Doom's own stock `SPC t` toggle group):
| Key | Action |
|---|---|
| `SPC t R` | `rainbow-delimiters-mode` — color-code matching bracket pairs |
| `SPC t h` | `rainbow-mode` — show hex/named colors with their actual color as background |
| `SPC t o` | `symbol-overlay-mode` — highlight all occurrences of the symbol at point |
