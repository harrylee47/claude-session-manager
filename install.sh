#!/bin/zsh
# Install Claude Code Session Manager
# Usage: ./install.sh

set -e

BIN_DIR="$HOME/.local/bin"
SKILL_DIR="$HOME/.claude/skills"

echo "Installing Claude Code Session Manager..."

# Install bin scripts
mkdir -p "$BIN_DIR"
for script in bin/claude-*; do
  cp "$script" "$BIN_DIR/"
  chmod +x "$BIN_DIR/$(basename "$script")"
done
echo "✓ Scripts installed to $BIN_DIR"

# Install skills
mkdir -p "$SKILL_DIR"
for skill_dir in skills/claude-*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$SKILL_DIR/$skill_name"
  cp "$skill_dir/SKILL.md" "$SKILL_DIR/$skill_name/"
done
echo "✓ Skills installed to $SKILL_DIR"

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "⚠ $BIN_DIR is not in your PATH. Add this to your ~/.zshrc:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Check tmux
if ! command -v tmux &>/dev/null; then
  echo ""
  echo "⚠ tmux is not installed. Install with: brew install tmux"
fi

echo ""
echo "Done! Run 'claude-help' to get started."
