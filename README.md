# configs

My personal dotfiles — Ghostty, Vim/Neovim, Zsh, Tmux, Hammerspoon, Herdr, and opencode configs.

## Setup (new machine)

```bash
git clone --recurse-submodules https://github.com/EdanSneh/configs.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Then:
1. Enter tokens when prompted (or run `./scripts/secret_setup.sh` later)
2. Grant Hammerspoon Accessibility permissions (System Settings → Privacy & Security → Accessibility)
3. `exec zsh`
4. `tmux + I` (install tmux plugins)

## Sync (push current state)

```bash
cd ~/dotfiles && ./sync.sh
git add -A && git commit -m "sync dotfiles" && git push
```

## What's included

| File | Description |
|---|---|
| `ghostty/config` | Ghostty terminal config (Wombat theme, toggle_visibility keybind) |
| `vimrc` | Vim config (Vundle, wombat256mod, sources shared.vim) |
| `nvim/` | Neovim config (LazyVim, treesitter, LSP, sources shared.vim) |
| `zshrc` | Zsh config (oh-my-zsh, autosuggestions, syntax highlighting) |
| `p10k.zsh` | Powerlevel10k prompt config (nerdfont-v3, lean style, icons) |
| `tmux.conf` | Tmux config (vi mode, TPM, resurrect/continuum) |
| `git/ignore` | Global gitignore (`.DS_Store`, `.plan/`, editor files, etc.) |
| `hammerspoon/init.lua` | Mouse button 3 → Ghostty toggle_visibility |
| `opencode/opencode.json` | opencode AI CLI config |
| `herdr/config.toml` | Herdr terminal workspace manager config (keybinds, theme, UI) |
| `scripts/secret_setup.sh` | Interactive prompt for GITLAB_TOKEN, GITHUB_TOKEN, and git credential store |

Secrets (GITLAB_TOKEN, GITHUB_TOKEN) live in `~/.zshrc.local` — never committed.
To redo secrets: `./scripts/secret_setup.sh`
