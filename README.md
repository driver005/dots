# My Personal Dotfiles (`dots`)

Custom configuration files for my development environment, including Neovim, Kitty, Tmux, and shell utilities.

---

## 🛠️ Requirements & Prerequisites

Before setting up these dotfiles, ensure you have installed:
- **JetBrains Mono Nerd Font** (installed locally on your operating system).
- **Terminal Emulator:** [Kitty](https://sw.kovidgoyal.net/kitty/) or Chrome-based Terminal (Secure Shell / hterm).
- **Text Editor:** [Neovim](https://neovim.io/) (v0.9+ recommended).
- **Terminal Multiplexer:** [Tmux](https://github.com/tmux/tmux) (optional if using Kitty).

---

## 🔤 Nerd Font & Font Setup

To ensure icons and ligatures display cleanly across desktop terminals and Chrome-based environments without rendering glitches or security blocks, follow these steps:

### 1. Automated Font Installation (Linux & macOS)
Install **JetBrains Mono Nerd Font** into your user font directory (`~/.local/share/fonts` on Linux, `~/Library/Fonts` on macOS):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)" _ JetBrainsMono
```

> **Note the `_` before `JetBrainsMono`.** With `bash -c '<script>' arg`, the first
> argument becomes `$0`, not `$1`. Without the placeholder the installer receives no
> font name, falls back to its interactive menu, and fails with
> `/dev/tty: No such device or address` / `No fonts selected` in any terminal
> without a controlling TTY (Chrome terminal, Secure Shell, CI, piped sessions).

**Fallback (no third-party script, official release only):**

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMono
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
  | tar -xJ -C ~/.local/share/fonts/JetBrainsMono
fc-cache -f
fc-list | grep -i "JetBrainsMono Nerd Font"   # verify
```

### 2. Chrome / hterm Preferences
`font-family` alone only works if the font is installed on the **machine running Chrome** (Windows/macOS/Linux desktop). On ChromeOS you cannot install system fonts, and fonts installed in the Linux container or on a remote host are invisible to Chrome. In that case load the font as a web font through `user-css`; hterm / Secure Shell supports this. The CSS below is from [mshaugh/nerdfont-webfonts](https://github.com/mshaugh/nerdfont-webfonts) and served through jsDelivr (pinned to a commit) because Secure Shell pages send a Cross-Origin-Embedder-Policy header: hosts without a `Cross-Origin-Resource-Policy` header, such as `*.github.io`, are blocked with `ERR_BLOCKED_BY_RESPONSE.NotSameOriginAfterDefaultedToSameOriginByCoep`. It provides JetBrainsMono Nerd Font Mono:

```javascript
// Run in the terminal tab's DevTools console (Ctrl+Shift+J), or paste the same
// values into Secure Shell -> Options ("font-family" and "Custom CSS (URI)").
term_.prefs_.set('font-family', '"JetBrainsMono NFM", monospace');
term_.prefs_.set('user-css', 'https://cdn.jsdelivr.net/gh/mshaugh/nerdfont-webfonts@c009b09b14e1de914a552a488b9d9306e0661c1a/build/jetbrainsmono-nfm.css');
```

If the font is installed locally on the client OS, set only `font-family` to `"JetBrainsMono Nerd Font Mono", "JetBrainsMono NFM", monospace` and leave `user-css` empty.

---

## ⚙️ Terminal & Environment Fixes

### Fix Tmux Cursor Jumping & Scrolling
If you experience jumping cursors or abnormal rendering while scrolling inside Tmux (especially when using Neovim animations like `snacks.nvim`), avoid dynamically passing `${TERM}`.

* **Incorrect (`tmux/conf.d/general.conf`):**
  ```tmux
  set-option -g default-terminal "${TERM}"
  ```
* **Correct:**
  ```tmux
  set-option -g default-terminal "tmux-256color"
  ```

*(Note: If you use **Kitty**, you can bypass Tmux entirely as Kitty supports multi-tab, splits, and modern protocols natively).*

---

## 📦 Installation & Setup

Clone the repository to your local machine:

```bash
git clone https://github.com/driver005/dots.git ~/.config/dots
```

Symlink the desired configurations to `$XDG_CONFIG_HOME`:

```bash
# Neovim
ln -s ~/.config/dots/nvim ~/.config/nvim

# Kitty
ln -s ~/.config/dots/kitty ~/.config/kitty

# Tmux
ln -s ~/.config/dots/tmux ~/.config/tmux
```
