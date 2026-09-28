#!/bin/bash

# Detect or set system architecture
ARCH="x86_64"
if [ -n "$1" ]; then
    ARCH="$1"
elif command -v uname &>/dev/null; then
    ARCH=$(uname -m)
fi

# Normalize architecture strings for GitHub release assets
NVIM_ARCH="$ARCH"
LAZYGIT_ARCH="$ARCH"

if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    NVIM_ARCH="arm64"
    LAZYGIT_ARCH="arm64"
elif [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    NVIM_ARCH="x86_64"
    LAZYGIT_ARCH="x86_64"
fi

echo "Building nvim for architecture: $ARCH"

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# 1. Install Neovim (if not installed)
if ! command_exists nvim; then
    echo "Neovim not found. Installing Neovim..."
    if command_exists pacman; then
        sudo pacman -S --noconfirm neovim
    elif command_exists apt; then
        curl -Lo "nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
        sudo rm -rf /opt/nvim
        sudo mkdir -p /opt/nvim
        sudo tar -C /opt/nvim --strip-components=1 -xzf nvim.tar.gz
        
        # Add to PATH if not already present
        if ! grep -q '/opt/nvim/bin' ~/.bashrc; then
            echo 'export PATH="$PATH:/opt/nvim/bin"' >> ~/.bashrc
        fi
        export PATH="$PATH:/opt/nvim/bin"
        rm -f nvim.tar.gz
    elif command_exists dnf; then
        sudo dnf install -y neovim
    elif command_exists brew; then
        brew install neovim
    else
        echo "Please install Neovim manually."
        exit 1
    fi
else
    echo "Neovim is already installed."
fi

# 2. Install fd (fd-find) if not installed
if ! command_exists fdfind && ! command_exists fd; then
    echo "Fd not found. Installing fd-find..."
    if command_exists pacman; then
        sudo pacman -S --noconfirm fd
    elif command_exists apt; then
        sudo apt-get update -y
        sudo apt-get install -y fd-find
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    elif command_exists dnf; then
        sudo dnf install -y fd-find
    elif command_exists brew; then
        brew install fd
    fi
fi

# 3. Install lazygit if not installed
if ! command_exists lazygit; then
    echo "Lazygit not found. Installing Lazygit..."
    if command_exists pacman; then
        sudo pacman -S --noconfirm lazygit
    elif command_exists dnf; then
        sudo dnf install -y lazygit
    elif command_exists brew; then
        brew install lazygit
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
        rm -f lazygit.tar.gz lazygit
    fi
fi

echo "Neovim setup has been completed successfully!"
