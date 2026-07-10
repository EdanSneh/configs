# configs

My personal dotfiles — Ghostty, Vim, Zsh, Tmux, Hammerspoon, and opencode configs.

## Setup (new machine)

```bash
git clone --recurse-submodules https://github.com/EdanSneh/configs.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Then:
1. Edit `~/.zshrc.local` with your secrets (see `zshrc.local.template`)
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
| `vimrc` | Vim config (Vundle plugins, wombat256mod, sane defaults) |
| `zshrc` | Zsh config (oh-my-zsh, autosuggestions, syntax highlighting) |
| `tmux.conf` | Tmux config (vi mode, TPM, resurrect/continuum) |
| `hammerspoon/init.lua` | Mouse button 3 → Ghostty toggle_visibility |
| `opencode/opencode.json` | opencode AI CLI config |

Secrets (GITLAB_TOKEN, etc.) live in `~/.zshrc.local` — never committed.
