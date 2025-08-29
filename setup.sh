#!/usr/bin/env bash

# function to check if a command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# 2. install git and curl (if not installed)
if ! command_exists git; then
	echo "git not found. installing git..."
	sudo apt install -y git
fi

if ! command_exists curl; then
	echo "curl not found. installing curl..."
	sudo apt install -y curl
fi

if ! command_exists zsh; then
	echo "zsh not found. installing zsh..."
	sudo apt install -y zsh
fi

# Install fzf if not installed
if ! command_exists fzf; then
	echo "Fzf not found. Installing fzf..."
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	sudo ~/.fzf/install
fi

# Install fzf if not installed
if ! command_exists starship; then
	echo "Starship not found. Installing starship..."
	curl -sS https://starship.rs/install.sh | sudo sh
fi

if ! command_exists zoxide; then
	echo "zoxide not found. installing zoxide..."
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sudo sh
fi

# Install tmux if not installed
if ! command_exists tmux; then
	echo "Tmux not found. Installing tmux..."
	sudo apt install -y tmux
fi

if [ -d "~/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/time
fi

# Install stow if not installed
if ! command_exists stow; then
	echo "Stow not found. Installing stow..."
	sudo apt install -y stow
fi

# Install nvim if not installed
if ! command_exists nvim; then
	echo "Nvim not found. Installing nvim..."
	./nvim/install_nvim.sh
fi

stow .

tmux new-session -d -s rtb123
tmux send-keys "tmux source ~/.config/tmux/tmux.conf" C-m
tmux kill-session -t rtb123

zsh -c "source ~/.config/zshrc/.zshrc"
