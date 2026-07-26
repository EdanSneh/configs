#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Parse flags ---
INSTALL_GUI=true
for arg in "$@"; do
  case "$arg" in
    --no-gui) INSTALL_GUI=false ;;
  esac
done

echo "=== Installing dotfiles from $REPO_DIR ==="

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
else
  echo "Homebrew already installed."
fi

# --- CLI tools ---
echo "Installing CLI tools..."

if ! command -v nvim >/dev/null 2>&1; then
  echo "Installing neovim..."
  brew install neovim
else
  echo "neovim already installed, skipping."
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "Installing tmux..."
  brew install tmux
else
  echo "tmux already installed, skipping."
fi

if ! command -v herdr >/dev/null 2>&1; then
  echo "Installing herdr..."
  brew install herdr
else
  echo "herdr already installed, skipping."
fi

if ! command -v opencode >/dev/null 2>&1; then
  echo "Installing opencode..."
  brew tap anomalyco/tap
  brew install opencode
else
  echo "opencode already installed, skipping."
fi

# --- GUI tools (skip with --no-gui) ---
if [ "$INSTALL_GUI" = true ]; then
  echo "Installing GUI tools..."

  if [ ! -d "/Applications/Ghostty.app" ]; then
    echo "Installing ghostty..."
    brew install --cask ghostty
  else
    echo "ghostty already installed, skipping."
  fi

  if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo "Installing hammerspoon..."
    brew install --cask hammerspoon
  else
    echo "hammerspoon already installed, skipping."
  fi
else
  echo "Skipping GUI tools (--no-gui)."
fi

# --- oh-my-zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed, skipping."
fi

# --- Submodules (zsh plugins/themes) ---
echo "Updating git submodules..."
cd "$REPO_DIR"
git submodule update --init --recursive

# --- Link oh-my-zsh custom plugins/themes ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

for item in "$REPO_DIR/oh-my-zsh-custom/plugins/"*; do
  name="$(basename "$item")"
  [ -d "$item" ] || continue
  ln -sfn "$item" "$ZSH_CUSTOM/plugins/$name"
  echo "  linked plugin: $name"
done

for item in "$REPO_DIR/oh-my-zsh-custom/themes/"*; do
  name="$(basename "$item")"
  [ -d "$item" ] || continue
  ln -sfn "$item" "$ZSH_CUSTOM/themes/$name"
  # If the theme is a directory with a .zsh-theme file inside, also link the file
  # so oh-my-zsh's is_theme() can find it
  if [ -f "$item/$name.zsh-theme" ]; then
    ln -sfn "$item/$name.zsh-theme" "$ZSH_CUSTOM/themes/$name.zsh-theme"
  fi
  echo "  linked theme: $name"
done

# --- TPM (tmux plugin manager) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already installed, skipping."
fi

# --- Vundle (vim plugin manager) ---
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  echo "Installing Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim "$HOME/.vim/bundle/Vundle.vim"
else
  echo "Vundle already installed, skipping."
fi

# --- Symlinks ---
link() {
  local target="$1" link_path="$2"
  mkdir -p "$(dirname "$link_path")"
  ln -sfn "$target" "$link_path"
  echo "  linked: $link_path -> $target"
}

echo "Creating symlinks..."

# Ghostty — symlink the whole dir (but keep themes if user has extras)
if [ ! -e "$HOME/.config/ghostty" ] || [ -L "$HOME/.config/ghostty" ]; then
  ln -sfn "$REPO_DIR/ghostty" "$HOME/.config/ghostty"
  echo "  linked: ~/.config/ghostty -> $REPO_DIR/ghostty"
else
  echo "  ~/.config/ghostty exists and is not a symlink — linking individual files"
  link "$REPO_DIR/ghostty/config" "$HOME/.config/ghostty/config"
  for theme in "$REPO_DIR/ghostty/themes/"*; do
    [ -f "$theme" ] && link "$theme" "$HOME/.config/ghostty/themes/$(basename "$theme")"
  done
fi

# Neovim (LazyVim) — symlink the whole config dir
if [ ! -e "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
  ln -sfn "$REPO_DIR/nvim" "$HOME/.config/nvim"
  echo "  linked: ~/.config/nvim -> $REPO_DIR/nvim"
else
  echo "  ~/.config/nvim exists and is not a symlink — skipping"
fi

# Vim (shares settings with nvim via shared.vim)
link "$REPO_DIR/vimrc" "$HOME/.vimrc"

# Zsh
link "$REPO_DIR/zshrc" "$HOME/.zshrc"

# Powerlevel10k config
link "$REPO_DIR/p10k.zsh" "$HOME/.p10k.zsh"

# Hammerspoon (keep dir real for Spoons, link only init.lua)
mkdir -p "$HOME/.hammerspoon"
link "$REPO_DIR/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

# Tmux
link "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"

# Global gitignore
mkdir -p "$HOME/.config/git"
link "$REPO_DIR/git/ignore" "$HOME/.config/git/ignore"
git config --global core.excludesfile "$HOME/.config/git/ignore"

# Opencode (keep dir real for node_modules/plugins, link individual files)
mkdir -p "$HOME/.config/opencode"
link "$REPO_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
link "$REPO_DIR/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
link "$REPO_DIR/opencode/.gitignore" "$HOME/.config/opencode/.gitignore"

# Herdr (keep dir real for sockets/logs/session state, link only config.toml)
mkdir -p "$HOME/.config/herdr"
link "$REPO_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# --- Secrets (interactive) ---
"$REPO_DIR/scripts/secret_setup.sh"

# --- Install vim plugins (Vundle) ---
if command -v vim >/dev/null 2>&1; then
  echo "Installing vim plugins..."
  vim +PluginInstall +qall 2>/dev/null || echo "  (vim PluginInstall may need a restart)"
else
  echo "vim not found — skipping plugin install. Install vim and run: vim +PluginInstall +qall"
fi

# --- Reload tmux if running ---
if command -v tmux >/dev/null 2>&1 && [ -n "${TMUX:-}" ]; then
  tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "Reloaded tmux config."
fi

echo ""
echo "=== Done! ==="
echo ""
echo "Remaining manual steps:"
echo "  1. If you skipped the token prompts, run: ./scripts/secret_setup.sh"
echo "  2. Grant Hammerspoon Accessibility permissions:"
echo "     System Settings -> Privacy & Security -> Accessibility -> Hammerspoon"
echo "  3. Restart your shell: exec zsh"
echo "  4. Install tmux plugins: tmux + I (capital I)"
