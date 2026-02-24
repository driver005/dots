#!/bin/bash
# Set a default value for the ARCH variable
ARCH="x86_64"
# Check if the user provided a command-line argument
if [ -n "$1" ]; then
    ARCH="$1"
fi
# Now you can use the ARCH variable in your 'make' command
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
        curl -Lo "nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH}.tar.gz"
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim.tar.gz
        echo "export PATH=\"\$PATH:/opt/nvim-linux-${ARCH}/bin\"" >> ~/.bashrc
        rm nvim.tar.gz
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

# Install fd (fd-find) if not installed
if ! command_exists fdfind && ! command_exists fd; then
    echo "Fd not found. Installing fd-find..."
    if command_exists pacman; then
        sudo pacman -S --noconfirm fd
    else
        sudo apt-get install -y fd-find
        sudo ln -s $(which fdfind) /usr/local/bin/fd
    fi
fi

# Install lazygit if not installed
if ! command_exists lazygit; then
    echo "Lazygit not found. Installing Lazygit..."
    if command_exists pacman; then
        sudo pacman -S --noconfirm lazygit
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
        rm lazygit.tar.gz lazygit
    fi
fi

echo "Neovim setup has been completed successfully!"
