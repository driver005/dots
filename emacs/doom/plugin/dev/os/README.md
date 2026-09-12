# `:os` — enabled modules

## `macos`
Conditionally enabled only `(:if (featurep :system 'macos) macos)` — a no-op on this Linux system. Provides macOS compatibility fixes (menu bar, `pbcopy`/`pbpaste` clipboard integration, etc.) when running on macOS.

No flags, requires a macOS environment. Nothing to install here on Linux.

`tty` (terminal-Emacs compatibility improvements) is commented out and not active.
