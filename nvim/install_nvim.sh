#!/bin/bash

# Function to check if a command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# 1. Install Neovim (if not installed)
if ! command_exists nvim; then
	echo "Neovim not found. Installing Neovim..."
	# For Debian/Ubuntu-based systems
	if command_exists apt; then
		mkdir -p "tmp"
		cd tmp

  		ARCH="arm64"
		# Download the latest Neovim tarball
		curl -Lo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-{$ARCH}.tar.gz"
		#curl -Lo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

  		# Extract and install Neovim in one step
		tar -xvzf nvim.tar.gz --strip-components=2 nvim-linux-{$ARCH}/bin/nvim
		sudo install nvim -D -t /usr/local/bin/

		# Clean up tarball
		rm nvim.tar.gz
  		cd ..
 	# For RedHat/CentOS-based systems
	elif command_exists dnf; then
		sudo dnf install -y neovim
	# For macOS using Homebrew
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
if ! command_exists fdfind; then
	echo "Fd not found. Installing fd-find..."
	sudo apt-get install -y fd-find
	# Create a symlink to make `fd` accessible
	sudo ln -s $(which fdfind) /usr/local/bin/fd
fi

if ! command_exists lazygit; then
	echo "Lazygit not found. Installing Lazygit..."
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit -D -t /usr/local/bin/
fi

# 3. Install LazyVim (if not installed)
# echo "Installing LazyVim plugin manager..."

# Clone the LazyVim repository into Neovim's configuration directory
# if [ ! -d "$HOME/.config/nvim" ]; then
	# mkdir -p "$HOME/.config/nvim"

	# LazyVim installation: cloning the LazyVim repository
	# git clone https://github.com/LazyVim/LazyVim.git "$HOME/.config/nvim"
# fi

echo "LazyVim has been installed successfully!"
