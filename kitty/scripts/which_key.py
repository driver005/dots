#!/usr/bin/env python3
"""LazyVim-style which-key popup for kitty's ctrl+space leader.

kitty has no keymap-popup plugin. Kittens mapped via `map ... kitten x.py`
open in an overlay window, so this paints the grouped leader map and waits
for a keypress to dismiss. Bound to ctrl+space>space.
Keep in sync with the leader binds in kitty.conf.
"""
import sys

BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[36m"
MAG = "\033[35m"
YEL = "\033[33m"
RST = "\033[0m"

# group key -> (label, [(sub, desc), ...])
GROUPS = [
    ("b", "windows / splits", [
        ("w", "other pane"),
        ("d", "close pane"),
        ("- / |", "split below / right"),
        ("m", "maximize (zoom)"),
        ("=", "balance panes"),
        ("h/j/k/l", "focus pane"),
        ("H/J/K/L", "reorder pane (move/swap)"),
    ]),
    ("w", "buffers (tabs)", [
        ("b", "last tab"),
        ("d", "close tab"),
        ("o", "close other tabs"),
        ("n", "new tab"),
        ("h / l", "prev / next tab"),
        ("H / L", "reorder tab (move)"),
    ]),
    ("<tab>", "tabs (os windows)", [
        ("<tab>", "new os window"),
        ("d", "close os window"),
    ]),
    ("u", "ui", [
        ("t / b", "toggle theme (mocha/latte)"),
        ("C", "colorscheme picker"),
    ]),
    ("q", "quit / session", [
        ("q", "save session + quit window"),
        ("d", "quit window (discard)"),
        ("s", "save session only"),
    ]),
    ("g", "git", [
        ("g", "lazygit"),
    ]),
    ("f", "find", [
        ("f", "files (fzf -> editor)"),
    ]),
    ("s", "search", [
        ("g", "grep (rg -> editor)"),
    ]),
    ("/", "scrollback search", [
        ("/", "search history"),
        ("n / N", "next / prev match (mark)"),
    ]),
    ("a", "ai", [
        ("l", "claude cli"),
    ]),
    ("m", "xmake", [
        ("b", "build"),
        ("r", "run"),
        ("c", "clean"),
        ("d", "debug"),
    ]),
]


def main(args: list[str]):
    out = sys.stdout
    out.write("\n")
    out.write(f"  {BOLD}{CYAN}which-key{RST}  {DIM}<leader> = ctrl+space{RST}\n\n")
    for gkey, glabel, subs in GROUPS:
        out.write(f"  {MAG}{gkey}{RST}  {BOLD}+{glabel}{RST}\n")
        for sub, desc in subs:
            out.write(f"      {YEL}{sub:<9}{RST} {desc}\n")
        out.write("\n")
    out.write(f"  {DIM}top-level: <space> files  ? this menu  - split  | vsplit{RST}\n")
    out.write(f"  {DIM}also: alt+h/j/k/l nav panes (nvim <-> kitty){RST}\n")
    out.write(f"  {DIM}also: <leader> h/l prev/next tab (short for w h/l){RST}\n")
    out.write(f"  {DIM}nvim-only groups (c/d/h/t/x) live inside nvim{RST}\n")
    out.write(f"  {DIM}press any key to close{RST}\n")
    out.flush()

    # Single-key dismiss via cbreak; fall back to line input.
    try:
        import termios
        import tty

        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setcbreak(fd)
            sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
    except Exception:
        try:
            input()
        except (EOFError, KeyboardInterrupt):
            pass
    return None


def handle_result(args, answer, target_window_id, boss):
    pass
