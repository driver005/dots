# `:term` — enabled modules

Only one terminal backend is active — `eshell`, `shell`, `term`, and `vterm` are all commented out in `modules.el` (mutually exclusive with `ghostel`, only one terminal emulator module makes sense at a time).

## `ghostel`
A modern terminal emulator for Emacs powered by `libghostty-vt` (Ghostty's own terminal engine). Supports synchronized output, the Kitty keyboard and graphics protocols, OSC 8 hyperlinks, and true color — genuinely better terminal fidelity than `vterm`.

Flags in use: none. Other flag available: `+everywhere` (integrates ghostel into compilation commands, comint, and eshell globally, not just as a standalone terminal buffer).

Requires:
- Emacs built with dynamic module support (`--with-modules`) — confirmed present on this system (`MODULES` shows in `system-configuration-features`).
- Linux/macOS/FreeBSD on `x86_64` or `aarch64`.
- Nothing to install ahead of time: the native module (written in Zig) self-installs on first `M-x ghostel` — it offers to download a prebuilt binary for your platform. Optional: install Zig 0.15 yourself if you'd rather compile it locally instead of downloading (`ghostel-module-auto-install` variable controls this, default `'ask`).

**No documented keybindings** in the module's own README — it behaves like any other terminal buffer in Emacs (standard `term`/`comint`-style interaction), no Doom-specific bindings layered on top yet.
