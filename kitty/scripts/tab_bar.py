"""Custom kitty tab bar: powerline tabs titled `user@host:dir`.

Enabled via `tab_bar_style custom` in kitty.conf. kitty imports this file
and calls draw_tab() per tab. We rewrite each tab's title to
`user@host:<cwd>` (cwd = the tab's active window, home-collapsed to ~),
then defer to the built-in powerline renderer. Dynamic + portable.
"""
import getpass
import os
import socket

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    draw_tab_with_powerline,
)

USER = getpass.getuser()
HOST = socket.gethostname()
HOME = os.path.expanduser("~")


def _tab_cwd(tab: TabBarData) -> str:
    """Home-collapsed cwd of the tab's active window, or '' if unavailable."""
    try:
        boss = get_boss()
        if boss is None:
            return ""
        for t in boss.all_tabs:
            if getattr(t, "id", None) == tab.tab_id:
                w = t.active_window
                cwd = (w.cwd_of_child if w else "") or ""
                if cwd == HOME:
                    return "~"
                if cwd.startswith(HOME + os.sep):
                    return "~" + cwd[len(HOME):]
                return cwd
    except Exception:
        pass
    return ""


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    cwd = _tab_cwd(tab)
    prompt = f"{USER}@{HOST}"
    title = f"{prompt}:{cwd}" if cwd else prompt
    tab = tab._replace(title=title)
    return draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
