# 🔮 Ghostforge

A complete, opinionated macOS terminal configuration built around [Ghostty](https://ghostty.org) — the GPU-accelerated terminal emulator. This repo includes everything you need to transform your terminal into a fast, beautiful, keyboard-centric workspace.

<p align="center">
  <img src="https://img.shields.io/badge/Terminal-Ghostty-blueviolet?style=for-the-badge&logo=ghost" alt="Ghostty">
  <img src="https://img.shields.io/badge/Shell-Zsh-green?style=for-the-badge&logo=gnu-bash" alt="Zsh">
  <img src="https://img.shields.io/badge/Theme-Catppuccin-pink?style=for-the-badge" alt="Catppuccin">
  <img src="https://img.shields.io/badge/Font-JetBrains%20Mono-orange?style=for-the-badge&logo=jetbrains" alt="Font">
  <img src="https://img.shields.io/badge/Platform-macOS-lightgrey?style=for-the-badge&logo=apple" alt="macOS">
</p>

---

## ✨ Features

| Category | What You Get |
|----------|-------------|
| 🎨 **Appearance** | Catppuccin Mocha/Latte auto-theme, glassmorphism (blur + opacity), dimmed unfocused panes |
| ⌨️ **Keyboard** | Vim-style split navigation (`Alt+HJKL`), zoom toggle, tab management |
| 🚀 **Prompt** | [Starship](https://starship.rs) [Jetpack](https://starship.rs/presets/jetpack) preset with Nerd Font icons — two-line left prompt with git metrics, battery, node/python version, command timer |
| 📂 **Navigation** | [Zoxide](https://github.com/ajeetdsouza/zoxide) smart `cd` + [fzf](https://github.com/junegunn/fzf) fuzzy finder |
| 🛠️ **Modern Tools** | `eza` → `ls`, `bat` → `cat`, `fd` → `find`, `rg` → `grep`, `dust` → `du`, `btop` → `top` |
| 📁 **File Manager** | [Yazi](https://yazi-rs.github.io) terminal file manager with directory persistence |
| 🔀 **Git** | [lazygit](https://github.com/jesseduffield/lazygit) TUI + [delta](https://github.com/dandavella/delta) syntax-highlighted diffs |

---

## 🚀 Quick Install

**Prerequisites:** [Homebrew](https://brew.sh) must be installed.

```bash
# Clone the repo
git clone https://github.com/KevinArce/ghostforge.git
cd ghostforge

# Run the installer
chmod +x install.sh
./install.sh
```

That's it. Open **Ghostty** and you're ready to go.

> [!NOTE]
> The installer will **backup your existing `.zshrc`** before overwriting it. The backup is saved as `~/.zshrc.backup.<timestamp>`.

---

## 📦 What Gets Installed

### Terminal & Font
| Package | Type | Description |
|---------|------|-------------|
| `ghostty` | Cask | GPU-accelerated terminal emulator |
| `font-jetbrains-mono-nerd-font` | Cask | JetBrains Mono with Nerd Font icons |

### Shell Enhancements
| Package | Description |
|---------|-------------|
| `starship` | Cross-shell prompt with git/language integration |
| `zoxide` | Smarter `cd` that learns your habits |
| `fzf` | Fuzzy finder for files, history, and directories |
| `zsh-autosuggestions` | Fish-like inline history suggestions |
| `zsh-syntax-highlighting` | Real-time command syntax coloring |

### Modern Unix Replacements
| Package | Replaces | Why |
|---------|----------|-----|
| `bat` | `cat` | Syntax highlighting, line numbers |
| `eza` | `ls` | Icons, git status, tree view |
| `fd` | `find` | 5x faster, simpler syntax |
| `ripgrep` | `grep` | 10x faster, respects `.gitignore` |
| `dust` | `du` | Visual disk usage bars |
| `btop` | `top` | Beautiful system monitor |
| `yazi` | `ranger` | Blazing fast file manager |
| `lazygit` | `git` | Full git TUI |
| `git-delta` | `diff` | Syntax-highlighted git diffs |
| `tmux` | — | Terminal multiplexer |

---

## 📁 Repository Structure

```
ghostforge/
├── README.md            # You are here
├── install.sh           # One-command setup script
├── docs/
│   └── USER_GUIDE.md    # Full tutorial with shortcuts & commands
└── configs/
    ├── ghostty_config                 # → ~/.config/ghostty/config
    ├── starship.toml                  # → ~/.config/starship.toml
    ├── .zshrc                         # → ~/.zshrc
    ├── catppuccin-mocha.terminal      # Terminal.app profile (manual import)
    └── vscode-terminal-settings.json  # VS Code integrated terminal (manual merge)
```

---

## ⌨️ Key Shortcuts (Cheat Sheet)

### Ghostty Window Management

| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close surface |
| `Cmd+Shift+[` / `]` | Previous / Next tab |
| `Ctrl+Shift+D` | Split ↓ |
| `Ctrl+Shift+→` | Split → |
| `Ctrl+Shift+W` | Close split |
| `Alt+H/J/K/L` | Navigate splits (vim) |
| `Alt+Z` | Zoom / Unzoom pane |

### Shell Navigation

| Shortcut / Command | Action |
|--------------------|--------|
| `z <query>` | Smart jump to directory |
| `cdi` | Interactive fuzzy directory picker |
| `Ctrl+R` | Fuzzy search history |
| `Ctrl+T` | Fuzzy find file |
| `Alt+C` | Fuzzy `cd` into directory |
| `y` | Open Yazi file manager |
| `lg` | Open lazygit |

### Aliases

| Alias | Runs |
|-------|------|
| `ls` | `eza --icons` |
| `ll` | `eza -lh --git --icons` |
| `la` | `eza -lha --git --icons` |
| `cat` | `bat --style=plain` |
| `grep` | `rg` |
| `find` | `fd` |
| `du` | `dust` |
| `top` | `btop` |

---

## 🎨 Customization

All config files live in `configs/` — edit them, re-run `install.sh`, and you're updated.

| What | File | Docs |
|------|------|------|
| Terminal appearance & keybinds | `configs/ghostty_config` | [Ghostty Config Reference](https://ghostty.org/docs/config/reference) |
| Prompt modules & colors | `configs/starship.toml` | [Starship Configuration](https://starship.rs/config/) |
| Aliases, plugins & shell init | `configs/.zshrc` | — |

### Quick Tweaks

```ini
# Ghostty: adjust transparency (configs/ghostty_config)
background-opacity = 0.85   # 0.0 (transparent) → 1.0 (opaque)
background-blur = 30        # Higher = more frosted glass

# Ghostty: change font size
font-size = 14
```

---

## 🖥️ Matching Look in Terminal.app & VS Code

Ghostty is the primary target, but the Starship prompt and `eza` icons turn into boxes in any terminal that isn't using a Nerd Font. Two drop-in configs bring the built-in macOS Terminal and VS Code's integrated terminal in line: same font, same Catppuccin Mocha palette (values copied from Ghostty's bundled theme), same bar cursor. `install.sh` does not touch these — apply them by hand.

### Terminal.app

```bash
# Imports a "Catppuccin Mocha" profile (JetBrainsMono Nerd Font 13.5, 90% opacity + blur)
open configs/catppuccin-mocha.terminal

# Make it the default for new and startup windows
osascript -e 'tell app "Terminal" to set default settings to settings set "Catppuccin Mocha"' \
          -e 'tell app "Terminal" to set startup settings to settings set "Catppuccin Mocha"'
```

Your existing profiles are left untouched — switch back any time in **Terminal → Settings → Profiles**.

### VS Code

Merge `configs/vscode-terminal-settings.json` into your user `settings.json` (`Cmd+Shift+P` → *Preferences: Open User Settings (JSON)*). Two things worth knowing:

- The colour block is scoped to the **Dark Modern** theme. If you use a different theme, rename the `"[Dark Modern]"` key to match it.
- `terminal.integrated.minimumContrastRatio` is set to `1`. VS Code's default of `4.5` silently recolours the palette, which is why terminal colours never quite match a standalone terminal.

---

## 📖 Full Documentation

See the **[User Guide](docs/USER_GUIDE.md)** for:
- Detailed walkthrough of every tool
- All keybindings and shortcuts
- Git workflow tips
- Yazi navigation reference
- Known issues and workarounds

---

## 🔄 Updating

```bash
# Pull latest changes
git pull

# Re-run installer (it's idempotent)
./install.sh
```

---

## ⚠️ Notes

- **macOS only** — designed for macOS with Apple Silicon (Homebrew at `/opt/homebrew`)
- **NVM compatible** — the `.zshrc` includes NVM initialization (edit if you use a different Node manager)
- **`cd` is aliased to `z`** — use `builtin cd` if you need the original behavior
- **`find`/`grep` are aliased** — use `/usr/bin/find` or `/usr/bin/grep` for the originals

---

## 📄 License

MIT — do whatever you want with it.
