#!/usr/bin/env bash
set -e

# Oh my tmux! installer wrapper for this dotfiles repo.
# Clones/updates oh-my-tmux and wires it into ~/.config/tmux.

OH_MY_TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/oh-my-tmux"
OH_MY_TMUX_REPO="https://github.com/gpakosz/.tmux.git"
TMUX_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
TMUX_CONF="$TMUX_CONF_DIR/tmux.conf"

# Path to this script's directory so we can find repo files when called from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

command_exists() {
    command -v "$1" &>/dev/null
}

if ! command_exists tmux; then
    echo "tmux not found. please install tmux first."
    exit 1
fi

if ! command_exists git; then
    echo "git not found. please install git first."
    exit 1
fi

mkdir -p "$TMUX_CONF_DIR"

# Clone or update Oh my tmux!
if [ -d "$OH_MY_TMUX_DIR/.git" ]; then
    echo "Updating Oh my tmux!..."
    git -C "$OH_MY_TMUX_DIR" pull --ff-only
else
    echo "Cloning Oh my tmux!..."
    rm -rf "$OH_MY_TMUX_DIR"
    git clone --depth 1 "$OH_MY_TMUX_REPO" "$OH_MY_TMUX_DIR"
fi

# Wire Oh my tmux! main config
ln -snf "$OH_MY_TMUX_DIR/.tmux.conf" "$TMUX_CONF"

# Our tmux.conf.local is stowed into ~/.config/tmux/tmux.conf.local by GNU Stow.
# This script only wires the Oh my tmux! main config.

# Oh my tmux! expects plugins next to tmux.conf when config lives under
# ~/.config/tmux, so we install TPM and plugins there instead of ~/.tmux/plugins.
TPM_DIR="$TMUX_CONF_DIR/plugins/tpm"
if [ ! -d "$TPM_DIR/.git" ]; then
    echo "Installing TPM..."
    rm -rf "$TPM_DIR"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Pre-install tmux-which-key so we can seed its config before TPM loads it.
WK_DIR="$TMUX_CONF_DIR/plugins/tmux-which-key"
WK_REPO="https://github.com/alexwforsythe/tmux-which-key.git"
if [ ! -d "$WK_DIR/.git" ]; then
    echo "Preparing tmux-which-key..."
    rm -rf "$WK_DIR"
    git clone --depth 1 --recurse-submodules "$WK_REPO" "$WK_DIR"
fi

# Copy custom which-key config and force a rebuild on next load.
WK_CONFIG_SRC="$DOTS_DIR/tmux/which-key-config.yaml"
WK_CONFIG_DST="$WK_DIR/config.yaml"
if [ -f "$WK_CONFIG_SRC" ]; then
    cp -f "$WK_CONFIG_SRC" "$WK_CONFIG_DST"
    rm -f "$WK_DIR/plugin/init.tmux"
    echo "Applied custom tmux-which-key config."
fi

# Copy wrapper scripts used by the which-key menu.
SCRIPTS_SRC="$DOTS_DIR/tmux/scripts"
SCRIPTS_DST="$TMUX_CONF_DIR/scripts"
if [ -d "$SCRIPTS_SRC" ]; then
    mkdir -p "$SCRIPTS_DST"
    cp -f "$SCRIPTS_SRC"/*.sh "$SCRIPTS_DST/"
    chmod +x "$SCRIPTS_DST"/*.sh
    echo "Copied tmux wrapper scripts."
fi

# Copy config variants (terminal.conf, tor.conf) - alternate entry points
# launched with `tmux -f ~/.config/tmux/<variant>.conf`.
for variant in "$DOTS_DIR"/tmux/*.conf; do
    [ -f "$variant" ] && cp -f "$variant" "$TMUX_CONF_DIR/" && echo "Copied $(basename "$variant")."
done

# Copy session-launcher + workspace util scripts (1amSimp1e pattern + custom).
for sub in utils sessions; do
    SRC="$DOTS_DIR/tmux/$sub"
    DST="$TMUX_CONF_DIR/$sub"
    if [ -d "$SRC" ]; then
        mkdir -p "$DST"
        cp -f "$SRC"/*.sh "$DST/"
        chmod +x "$DST"/*.sh
        echo "Copied tmux $sub scripts."
    fi
done

# Warn if no clipboard tool is available for tmux-yank
if ! command_exists wl-copy && ! command_exists xsel && ! command_exists xclip; then
    echo "Warning: no clipboard tool found (wl-copy, xsel, or xclip). tmux-yank may not work."
fi

# Trigger TPM plugin install by starting a temporary tmux session.
# Oh my tmux! installs/updates plugins automatically on launch/reload.
if ! tmux list-sessions &>/dev/null; then
    echo "Installing tmux plugins..."
    tmux new-session -d -s __tmux_setup__
    sleep 3
    tmux kill-session -t __tmux_setup__
fi

# If the which-key init was rebuilt from the example during the temp session,
# rebuild it from our custom config now.
if [ -f "$WK_CONFIG_DST" ] && [ -x "$(command -v python3)" ]; then
    python3 "$WK_DIR/plugin/build.py" "$WK_CONFIG_DST" "$WK_DIR/plugin/init.tmux"
fi

# Build tmux-thumbs (Rust binary) so the hint overlay works immediately.
THUMBS_DIR="$TMUX_CONF_DIR/plugins/tmux-thumbs"
if [ -d "$THUMBS_DIR" ] && [ -x "$(command -v cargo)" ]; then
    echo "Building tmux-thumbs..."
    (cd "$THUMBS_DIR" && cargo build --release 2>/dev/null) || echo "Warning: tmux-thumbs build failed. It will build on first use."
fi

# Make sure plugin scripts used by our keybindings are executable.
[ -f "$TMUX_CONF_DIR/plugins/tmux-jump/scripts/tmux-jump.rb" ] && chmod +x "$TMUX_CONF_DIR/plugins/tmux-jump/scripts/tmux-jump.rb"

# Source config if inside tmux
if [ -n "$TMUX" ]; then
    tmux source-file "$TMUX_CONF" || true
fi

echo "Tmux setup complete."
