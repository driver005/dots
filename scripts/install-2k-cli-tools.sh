#!/usr/bin/env bash
set -e

# Installer for 2kabhishek's standalone CLI tools (tdo, mkrepo, ghpm,
# git-sync, cmtr, gitrim). None of these ship a package - each is a
# single-script repo, installed by cloning + symlinking into PATH, same
# pattern 2kabhishek's own dots2k uses.

TOOLS_DIR="$HOME/.local/share/2k-cli-tools"
BIN_DIR="$HOME/.local/bin"

command_exists() {
    command -v "$1" &>/dev/null
}

for dep in gh fzf rg; do
    command_exists "$dep" || echo "Warning: $dep not found - some tools may not work fully."
done

mkdir -p "$TOOLS_DIR" "$BIN_DIR"

install_tool() {
    local repo="$1" script="$2" bin_name="$3"
    local name
    name="$(basename "$repo")"
    local dir="$TOOLS_DIR/$name"

    if [ -d "$dir/.git" ]; then
        echo "Updating $name..."
        git -C "$dir" pull --ff-only
    else
        echo "Cloning $name..."
        git clone --depth 1 "https://github.com/$repo" "$dir"
    fi

    chmod +x "$dir/$script"
    ln -sfnv "$dir/$script" "$BIN_DIR/$bin_name"
}

install_tool "2kabhishek/tdo" "tdo.sh" "tdo"
install_tool "2kabhishek/mkrepo" "mkrepo.sh" "mkrepo"
install_tool "2kabhishek/ghpm" "ghpm.sh" "ghpm"
install_tool "2kabhishek/git-sync" "git-sync.sh" "git-sync"
install_tool "2kabhishek/cmtr" "cmtr.sh" "cmtr"
install_tool "2kabhishek/gitrim" "gitrim.sh" "gitrim"

# tdo needs NOTES_DIR set. Create the notes dir and export NOTES_DIR in
# ~/.bashrc (idempotent - only appends if not already there). nushell gets
# it via the tracked dots/nushell/env.nu.
mkdir -p "$HOME/notes"
if ! grep -q "export NOTES_DIR=" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ''
        echo '# 2kabhishek/tdo note-taking CLI'
        echo 'export NOTES_DIR="$HOME/notes"'
    } >> "$HOME/.bashrc"
    echo "Added NOTES_DIR export to ~/.bashrc"
fi

# git-sync needs a repo-list config file (one path per line).
GIT_SYNC_CONFIG="$HOME/.config/git-sync"
if [ ! -f "$GIT_SYNC_CONFIG" ]; then
    cat > "$GIT_SYNC_CONFIG" <<'EOF'
# One git repo path per line. Managed by `git-sync config` / `git-sync c`.
EOF
    echo "Created $GIT_SYNC_CONFIG"
fi

echo "2k CLI tools installed: tdo, mkrepo, ghpm, git-sync, cmtr, gitrim"
