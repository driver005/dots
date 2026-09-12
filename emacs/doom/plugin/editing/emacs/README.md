# `:emacs` — enabled modules

`eww` is commented out (see the earlier discussion — Emacs's built-in web browser, not enabled here).

## `dired`
Makes the built-in `dired` file manager more functional (via `dirvish` augmentations).

Flags in use: none. Other flags available: `+dirvish` (full Ranger-like Dirvish UI instead of just augmentations to plain Dired), `+icons` (filetype icons + expand/collapse arrows).

Requires nothing mandatory on Linux (GNU `ls` is already what's used — the hard requirement is BSD/macOS-only). Optional, for richer previews: `poppler` (PDF), `imagemagick` (images), `ffmpegthumbnailer` (video), `mediainfo` (audio/video metadata), `tar`+`unzip` (archives) — all installed by `install-requirements.sh`.

| Key | Action |
|---|---|
| `SPC f d` | Find directory with dired |
| `SPC o -` | Jump to current directory in dired |
| `n` / `p` | Move down / up a line |
| `e` or `RET` | Visit file/directory on this line |
| `(` | Toggle detailed-info visibility |
| `q` | Exit dired buffer |
| `^` | Go up a directory |
| `m` / `u` | Mark / unmark a file |
| `D` | Delete a file |
| `+` | Create a directory |
| `?` | Help |
| `a` | Quick-access frequent directories (dirvish) |
| `f` | File info at cursor (dirvish) |
| `y...` | Copy marked files/paths (dirvish) |
| `s...` | Create symlinks (dirvish) |
| `S` | Sort by criteria (dirvish) |
| `M-m` / `M-s` / `M-e` | Marking commands / dirvish UI setup / "emerge" important files to top (dirvish) |
| `M-x dirvish` / `dirvish-dwim` / `dirvish-fd` / `dirvish-side` | Open with preview / smart layout / fd-search / project sidebar |

## `electric`
Smarter, keyword-based `electric-indent` (auto-reindent as you type, aware of language-specific keywords like `else`/`end`).

No flags, no external requirements, no keybindings — purely automatic.

## `ibuffer`
Replaces the default buffer-list (`C-x C-b`) with a full management view — sortable/filterable/groupable, mark-and-bulk-act like `dired` but for buffers.

Other flag available: `+icons` (filetype icons via `nerd-icons`).

No external requirements.

- `SPC b i` — open ibuffer.
- `SPC b I` — open ibuffer scoped to the current workspace only.

## `tramp`
Remote file editing over SSH/other protocols, transparently (open `/ssh:host:/path` like a local file).

No flags, no external requirements (needs an SSH client, already present on any normal Linux install).

No dedicated keybindings — it's transparent, standard `find-file` etc. just work with remote paths.

## `undo`
Persistent, session-surviving undo history.

Other flag available: `+tree` (use `undo-tree` instead of `undo-fu` — branching undo history + visualizer, but less stable).

No external requirements, no dedicated keybindings beyond standard `u`/`C-r` (evil) or `C-/`/`C-x u` (vanilla).

## `vc`
Version-control diff indicators sitting in the fringe (backs `:ui vc-gutter`, in the `ui` folder).

No flags. Requires `git` (already installed via `setup.sh`). No dedicated keybindings of its own.

---

## Repo-custom additions (this folder's own `.el` files, not Doom-stock)

- `filetype-warning.el` — logs `"No major mode/language support for: <file>"` to `*Messages*` (via plain `message`, not `display-warning`) whenever a file opens into `fundamental-mode` (no major mode matched it). No keybinding, purely a passive `find-file-hook`.
- `notifications.el` — enables `ednc-mode` (manage desktop D-Bus notifications from inside Emacs — they show in the mode line and become actable buffers instead of living in the system tray). No dedicated keybinding, it's an always-on minor mode.
- `wayland-focus.el` — forces newly-created GUI frames (initial startup + `emacsclient -c`) to grab window-manager focus, working around GNOME/mutter's Wayland focus-stealing prevention (see the earlier session discussion of the kitty-focus issue). Not a keybinding — runs automatically on frame creation.
