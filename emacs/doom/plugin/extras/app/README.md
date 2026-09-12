# `:app` — enabled modules

`emms` (music player, needs mpd/mpc — see the earlier discussion), `irc`, `rss` are commented out.

## `calendar`
Google Calendar integration (via `org-gcal`), shows upcoming deadlines/events.

No flags. Requires a Google Calendar account + an OAuth client ID for `org-gcal` — user-side setup (Google Cloud Console), no package to install.

No dedicated keybindings documented in the module's README.

## `everywhere`
Compose text anywhere on the desktop using Emacs — triggered from outside Emacs (e.g. a global hotkey), pops open a small Emacs frame, and pastes the result back into whatever app you triggered it from.

No flags. Requires (Linux/X11): `xclip`, `xdotool`, `xprop`, `xwininfo` — `install-requirements.sh` installs these. Note: this system is GNOME/Wayland — these X11 tools work via XWayland for X11-backed target windows, but a native-Wayland target application may not be controllable by `emacs-everywhere` (upstream limitation, not something a package install fixes). No global hotkey is wired up in this repo — you'd need to bind one yourself (e.g. a GNOME custom keyboard shortcut running `emacsclient --eval '(emacs-everywhere)'`).

| Key | Action |
|---|---|
| `C-c C-c` or `SPC q f` | Finish — paste content back into the original window |
| `C-c C-k` | Cancel without pasting |
