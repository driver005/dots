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

if [ ! -d "~/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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

stow .
tmux new-session -d -s rtb123
tmux send-keys "tmux source ~/.config/tmux/tmux.conf" C-m
tmux kill-session -t rtb123
# Source zshrc if it exists
if [ -f "$HOME/.config/zshrc/.zshrc" ]; then
    zsh -c "source ~/.config/zshrc/.zshrc"
else
    echo "Warning: ~/.config/zshrc/.zshrc not found, skipping..."
fi
