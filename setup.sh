#!/usr/bin/env bash
# Auto-detect architecture if not provided
if [ -z "$1" ]; then
    ARCH=$(uname -m)
    echo "No architecture provided. Auto-detected: $ARCH"
else
    ARCH="$1"
fi

echo "Building for architecture: $ARCH"

# function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Detect package manager and set install command
if command_exists pacman; then
    echo "Detected pacman package manager."
    PKG_INSTALL="sudo pacman -S --noconfirm"
    PKG_UPDATE="sudo pacman -Sy"
elif command_exists apt; then
    echo "Detected apt package manager."
    PKG_INSTALL="sudo apt install -y"
    PKG_UPDATE="sudo apt update"
else
    echo "Error: No supported package manager found (apt or pacman)."
    exit 1
fi

# Update package lists
$PKG_UPDATE

# Install git and curl (if not installed)
if ! command_exists git; then
    echo "git not found. installing git..."
    $PKG_INSTALL git
fi
if ! command_exists curl; then
    echo "curl not found. installing curl..."
    $PKG_INSTALL curl
fi
if ! command_exists zsh; then
    echo "zsh not found. installing zsh..."
    $PKG_INSTALL zsh
fi

# Install fzf if not installed
if ! command_exists fzf; then
    echo "Fzf not found. Installing fzf..."
    if command_exists pacman; then
        $PKG_INSTALL fzf
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        sudo ~/.fzf/install
    fi
fi

# Install starship if not installed
if ! command_exists starship; then
    echo "Starship not found. Installing starship..."
    curl -sS https://starship.rs/install.sh | sudo sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi

# Install zoxide if not installed
if ! command_exists zoxide; then
    echo "zoxide not found. installing zoxide..."
    if command_exists pacman; then
        $PKG_INSTALL zoxide
    else
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sudo sh
    fi
fi

# Install tmux if not installed
if ! command_exists tmux; then
    echo "Tmux not found. Installing tmux..."
    $PKG_INSTALL tmux
fi

# Install clipboard tool for tmux-yank
if ! command_exists wl-copy && ! command_exists xsel && ! command_exists xclip; then
    echo "Installing wl-clipboard for tmux-yank..."
    $PKG_INSTALL wl-clipboard
fi

# Install stow if not installed
if ! command_exists stow; then
    echo "Stow not found. Installing stow..."
    $PKG_INSTALL stow
fi

# Install ripgrep if not installed
if ! command_exists rg; then
    echo "Ripgrep not found. Installing ripgrep..."
    $PKG_INSTALL ripgrep
fi

# Install sysstat for tmux-cpu accurate readings
if ! command_exists iostat; then
    echo "sysstat not found. Installing sysstat..."
    $PKG_INSTALL sysstat
fi

# Install tmux plugin dependencies
if ! command_exists ruby; then
    echo "ruby not found. Installing ruby (required by tmux-jump)..."
    $PKG_INSTALL ruby
fi

# proxychains-ng + tor: for the tor.conf tmux variant (proxychains-wrapped
# shells route traffic through Tor).
if ! command_exists proxychains && ! command_exists proxychains4; then
    echo "proxychains not found. Installing (required by tor.conf variant)..."
    if command_exists pacman; then
        $PKG_INSTALL proxychains-ng
    else
        $PKG_INSTALL proxychains4
    fi
fi
if ! command_exists tor; then
    echo "tor not found. Installing (required by tor.conf variant)..."
    $PKG_INSTALL tor
fi

# libtmux: Python dep for tmux-window-name (smart window naming). Without
# it the plugin silently no-ops and windows fall back to "bash".
if ! python3 -c "import libtmux" 2>/dev/null; then
    echo "libtmux not found. Installing (required by tmux-window-name)..."
    if command_exists pacman; then
        $PKG_INSTALL python-libtmux
    else
        python3 -m pip install --user libtmux 2>/dev/null || \
            python3 -m pip install --user --break-system-packages libtmux
    fi
fi

if ! command_exists cargo; then
    echo "cargo not found. Installing cargo (required by tmux-thumbs)..."
    if command_exists pacman; then
        $PKG_INSTALL rust
    else
        $PKG_INSTALL cargo
    fi
fi

if ! command_exists fpp; then
    echo "fpp not found. Installing pathpicker (required by tmux-fpp)..."
    if command_exists pacman; then
        python3 -m pip install --user pathpicker 2>/dev/null || echo "Skipping pathpicker on pacman (install from AUR if needed)."
    else
        $PKG_INSTALL pathpicker || python3 -m pip install --user pathpicker
    fi
fi

if ! command_exists urlview; then
    echo "urlview not found. Installing urlview (required by tmux-urlview)..."
    $PKG_INSTALL urlview 2>/dev/null || echo "Skipping urlview (install manually if needed)."
fi

if ! command_exists playerctl; then
    echo "playerctl not found. Installing playerctl (required by tmux-now-playing)..."
    $PKG_INSTALL playerctl 2>/dev/null || echo "Skipping playerctl (now-playing will be disabled)."
fi

if ! command_exists fdfind && ! command_exists fd; then
    echo "fd not found. Installing fd (required by tmux-fzf-open-files-nvim)..."
    if command_exists pacman; then
        $PKG_INSTALL fd
    else
        $PKG_INSTALL fd-find
    fi
fi

if ! command_exists notify-send; then
    echo "notify-send not found. Installing libnotify (required by tmux-notify)..."
    if command_exists pacman; then
        $PKG_INSTALL libnotify
    else
        $PKG_INSTALL libnotify-bin
    fi
fi

# Install clangd if not installed
if ! command_exists clangd; then
    echo "clangd not found. Installing clangd..."
    $PKG_INSTALL clangd
fi

# Install luarocks if not installed
if ! command_exists luarocks; then
    echo "luarocks not found. Installing luarocks..."
    $PKG_INSTALL luarocks
fi

# Install ast-grep if not installed
if ! command_exists sg; then
    echo "ast-grep not found. Installing ast-grep..."
    if command_exists pacman; then
        $PKG_INSTALL ast-grep
    else
        wget -qO ast-grep.zip https://github.com/ast-grep/ast-grep/releases/latest/download/app-x86_64-unknown-linux-gnu.zip
        sudo unzip -q ast-grep.zip -d /usr/local/bin sg
        rm -rf ast-grep.zip
    fi
fi

# Install nvim if not installed
if ! command_exists nvim; then
    echo "Nvim not found. Installing nvim..."
    ./nvim/install_nvim.sh ${ARCH}
fi

# For c++
if command_exists pacman; then
    $PKG_INSTALL base-devel
else
    $PKG_INSTALL build-essential
fi

stow --no-folding .

# Starship prompt: symlink our config to where starship reads it
# (~/.config/starship.toml is a plain file, not a stow-managed dir).
ln -sfnv "$PWD/starship/starship.toml" "$HOME/.config/starship.toml"

# Install / update tmux config (oh-my-tmux + plugins)
./scripts/tmux-install.sh
tmux new-session -d -s rtb123
tmux send-keys "tmux source ~/.config/tmux/tmux.conf" C-m
tmux kill-session -t rtb123

# Install 2kabhishek CLI tools (tdo, mkrepo, ghpm, git-sync, cmtr, gitrim)
# + set up NOTES_DIR and the git-sync repo-list config.
./scripts/install-2k-cli-tools.sh

# Vimium (browser extension): can't be auto-installed - install it from the
# Chrome/Firefox store manually, then import dots/vimium/vimium.json via its
# options page (Import/Export Options). See dots/vimium/README.md.
echo "Vimium: install the extension manually, then import dots/vimium/vimium.json (see dots/vimium/README.md)."
# Source zshrc if it exists
if [ -f "$HOME/.config/zshrc/.zshrc" ]; then
    zsh -c "source ~/.config/zshrc/.zshrc"
else
    echo "Warning: ~/.config/zshrc/.zshrc not found, skipping..."
fi

# Kill any running tmux server so the next launch starts fresh - picks up
# NOTES_DIR (for the tdo status segment) and any other new env/plugins.
# NOTE: this closes all current tmux sessions.
echo "Killing tmux server so a fresh one picks up NOTES_DIR + new plugins..."
tmux kill-server 2>/dev/null || true
