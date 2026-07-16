#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=== Syncing dotfiles from \$HOME to repo ==="

# --- Ghostty ---
echo "Copying ghostty config..."
cp "$HOME/.config/ghostty/config" ghostty/config
cp "$HOME/.config/ghostty/themes/"* ghostty/themes/ 2>/dev/null || true

# --- Vim ---
echo "Copying vimrc..."
# Sanitize: update email, wrap ctags path
cat "$HOME/.vimrc" | \
  sed 's|ophirsneh@gmail.com|edan.sneh@gmail.com|g' | \
  sed 's|Ophir Sneh|Edan Sneh|g' | \
  sed "s|let g:Tlist_Ctags_Cmd='/usr/local/Cellar/ctags/5.8_1/bin/ctags'|if executable('ctags')\n  let g:Tlist_Ctags_Cmd=exepath('ctags')\nendif|" \
  > vimrc

# --- Zsh ---
echo "Copying zshrc (sanitizing secrets)..."
cat "$HOME/.zshrc" | \
  sed '/^export GITLAB_TOKEN=/d' | \
  sed '/^export UV_INDEX_GITLAB_USERNAME=/d' | \
  sed '/^export UV_INDEX_GITLAB_PASSWORD=/d' | \
  sed 's|^eval "$(pyenv init -)"|# pyenv\nif command -v pyenv >/dev/null 2>\&1; then\n  eval "$(pyenv init -)"\nfi|' | \
  sed 's|^source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc|# gcloud SDK\nif [ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]; then\n  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc\nfi|' | \
  sed 's|^source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc|if [ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]; then\n  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc\nfi|' \
  > zshrc

# Ensure source ~/.zshrc.local is present
if ! grep -q 'source ~/.zshrc.local' zshrc; then
  echo '' >> zshrc
  echo '# Local secrets (GITLAB_TOKEN, UV_INDEX_* etc.) — not in the repo' >> zshrc
  echo '[ -f ~/.zshrc.local ] && source ~/.zshrc.local' >> zshrc
fi

# --- Hammerspoon ---
echo "Copying hammerspoon init.lua..."
cp "$HOME/.hammerspoon/init.lua" hammerspoon/init.lua

# --- Tmux ---
echo "Copying tmux.conf..."
cp "$HOME/.tmux.conf" tmux.conf

# --- Opencode ---
echo "Copying opencode config..."
cp "$HOME/.config/opencode/opencode.json" opencode/opencode.json
cp "$HOME/.config/opencode/AGENTS.md" opencode/AGENTS.md

# --- Herdr ---
echo "Copying herdr config..."
cp "$HOME/.config/herdr/config.toml" herdr/config.toml

echo ""
echo "=== Sync complete. Review changes with: git diff ==="
echo "=== Commit and push with: git add -A && git commit -m 'sync dotfiles' && git push ==="
