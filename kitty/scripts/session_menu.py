#!/usr/bin/env python3
"""Session picker for kitty. Lists *.session files, asks which folder to
start it in, and opens it in a new OS window via `kitty --session`.
Bound to ctrl+space>S.

Add sessions by dropping a `<name>.session` file in conf/sessions/.
"""
import os
import subprocess
import sys

SESS_DIR = os.path.expanduser("~/.config/kitty/conf/sessions")
TMP_DIR = os.path.expanduser("~/.cache/kitty")

BOLD = "\033[1m"
CYAN = "\033[36m"
YEL = "\033[33m"
DIM = "\033[2m"
RST = "\033[0m"


def _sessions() -> list[str]:
    try:
        return sorted(
            f[:-len(".session")] for f in os.listdir(SESS_DIR)
            if f.endswith(".session")
        )
    except OSError:
        return []


def _read_key() -> str:
    try:
        import termios
        import tty
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setcbreak(fd)
            return sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
    except Exception:
        return (sys.stdin.readline() or "").strip()[:1]


def _ask_folder(default: str) -> str | None:
    """Line-mode prompt (cooked tty, backspace works) for the start folder.
    Returns an absolute existing directory, or None if cancelled/invalid.
    """
    sys.stdout.write(f"\n  folder to start in {DIM}[{default}]{RST}: ")
    sys.stdout.flush()
    try:
        folder = input().strip()
    except (EOFError, KeyboardInterrupt):
        return None
    folder = os.path.expanduser(os.path.expandvars(folder)) if folder else default
    folder = os.path.abspath(folder)
    if not os.path.isdir(folder):
        sys.stdout.write(f"\n  {DIM}not a directory: {folder} — cancelled{RST}\n")
        sys.stdout.flush()
        _read_key()
        return None
    return folder


def main(args: list[str]):
    out = sys.stdout
    sessions = _sessions()
    out.write("\n")
    out.write(f"  {BOLD}{CYAN}sessions{RST}\n\n")
    if not sessions:
        out.write(f"  {DIM}none found in {SESS_DIR}{RST}\n")
        out.write(f"\n  {DIM}press any key to close{RST}\n")
        out.flush()
        _read_key()
        return None
    for i, s in enumerate(sessions, 1):
        out.write(f"    {YEL}{i}{RST}  {s}\n")
    out.write(f"\n  {DIM}pick number (any other key cancels){RST}  ")
    out.flush()

    ch = _read_key()
    if not (ch.isdigit() and 1 <= int(ch) <= len(sessions)):
        return None

    name = sessions[int(ch) - 1]
    folder = _ask_folder(default=os.getcwd())
    if folder is None:
        return None

    session_path = os.path.join(SESS_DIR, name + ".session")
    body = open(session_path, encoding="utf-8").read()

    # kitty's `cd` directive only sets cwd on the tab currently being
    # built (Session.set_cwd -> tabs[-1].cwd); each `new_tab` starts a
    # fresh Tab with cwd=None, so it does NOT carry over. Re-inject
    # `cd <folder>` right after every new_tab (and once up front for the
    # implicit first tab) so every tab picks it up.
    os.makedirs(TMP_DIR, exist_ok=True)
    tmp_path = os.path.join(TMP_DIR, f"_{name}.session")
    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(f"cd {folder}\n")
        for line in body.splitlines():
            f.write(line + "\n")
            if line.strip().split(" ", 1)[0] == "new_tab":
                f.write(f"cd {folder}\n")

    subprocess.Popen(
        ["kitty", "--session", tmp_path],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return None


def handle_result(args, answer, target_window_id, boss):
    pass
