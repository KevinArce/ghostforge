# 📖 Ghostty Terminal — User Guide

A step-by-step guide to mastering your new terminal setup. Start here after running `install.sh`.

---

## Table of Contents

1. [Getting Started](#-getting-started)
2. [Ghostty Basics](#-ghostty-basics)
3. [Splits & Window Management](#-splits--window-management)
4. [Navigation Superpowers](#-navigation-superpowers)
5. [Modern Tool Replacements](#-modern-tool-replacements)
6. [Git Workflow](#-git-workflow)
7. [File Management with Yazi](#-file-management-with-yazi)
8. [Starship Prompt](#-starship-prompt)
9. [Configuration Reference](#-configuration-reference)
10. [Troubleshooting & Known Issues](#-troubleshooting--known-issues)

---

## 🎬 Getting Started

### Step 1: Open Ghostty

Launch Ghostty from **Spotlight** (`Cmd + Space` → type "Ghostty") or from `/Applications`.

You should see:
- A true-black (`#000000`) window — opaque, so it reads as pixels-off black on OLED
- The **Starship** prompt: your directory, git branch and the time on one line, with a `◎` on the line below
- The **JetBrains Mono Nerd Font** with clean icons

### Step 2: Try the Basics

```bash
# These familiar commands now use modern replacements:
ls           # → eza with icons and colors
cat README   # → bat with syntax highlighting
top          # → btop with beautiful graphs
```

### Step 3: Test the Keyboard

| Try This | What Happens |
|----------|-------------|
| `Ctrl+Shift+D` | Splits your terminal **down** |
| `Alt+K` | Jump back to the **top** pane |
| `Alt+Z` | **Zoom** the current pane (fullscreen) |
| `Alt+Z` again | **Unzoom** back to the grid |
| `Ctrl+R` | Fuzzy search your **command history** |

---

## 🔮 Ghostty Basics

### Tabs

| Shortcut | Action |
|----------|--------|
| `Cmd + T` | New tab |
| `Cmd + W` | Close current surface |
| `Cmd + Shift + [` | Previous tab |
| `Cmd + Shift + ]` | Next tab |
| `Cmd + 1` / `2` / `3` | Jump to tab by number |

### Appearance

Ghostty auto-switches between **Catppuccin Latte** (light) and **Catppuccin Mocha** (dark) based on your macOS system appearance. Toggle it in **System Settings → Appearance**.

The dark half is **Catppuccin Mocha Forge** (`~/.config/ghostty/themes/`) — stock Mocha with the background dropped to true black. The shade lives in the theme file rather than in `config`, because a `background =` line in `config` would override *both* modes and flatten the Latte half.

The window is fully opaque by default so the black stays black:

```ini
# In ~/.config/ghostty/config
background-opacity = 1.0   # 0.0 = fully transparent, 1.0 = opaque
background-blur = 0        # Only visible when opacity < 1.0
```

---

## 🪟 Splits & Window Management

Splits let you run multiple terminal sessions in one Ghostty window — no tmux needed for basic layouts.

### Creating Splits

| Shortcut | Action |
|----------|--------|
| `Ctrl + Shift + D` | Split **down** (horizontal split) |
| `Ctrl + Shift + →` | Split **right** (vertical split) |
| `Ctrl + Shift + W` | Close current surface |

### Navigating Between Splits (Vim-style)

| Shortcut | Direction |
|----------|-----------|
| `Alt + H` | ← Left |
| `Alt + J` | ↓ Down |
| `Alt + K` | ↑ Up |
| `Alt + L` | → Right |

### Zoom Toggle

Press `Alt + Z` to **maximize** the current pane to fill the entire window. Press `Alt + Z` again to **restore** the layout. This is perfect for:
- Reading long log output
- Focusing on one task temporarily
- Running fullscreen commands like `btop`

### Recommended Workflow

```
┌─────────────────────────────────┐
│          Code / Editor          │  ← Main work (top)
├────────────────┬────────────────┤
│   Terminal     │   Git / Logs   │  ← Support (bottom)
└────────────────┴────────────────┘
```

1. Start with `Ctrl+Shift+D` to split down
2. In the bottom pane, `Ctrl+Shift+→` to split right
3. Use `Alt+J/K` to hop between top and bottom
4. Use `Alt+H/L` to hop between bottom-left and bottom-right

---

## 🧭 Navigation Superpowers

### Zoxide — Smarter `cd`

Zoxide replaces `cd` and **learns** your most-visited directories. The more you use it, the smarter it gets.

```bash
# Basic usage (cd is aliased to z)
cd ~/Projects/Random       # Works normally AND teaches zoxide

# Smart jumping (after using it for a while)
z random                   # Jumps to ~/Projects/Random
z proj rand                # Multi-word fuzzy matching
z ..                       # Go up one level
z -                        # Go to previous directory

# Interactive mode
cdi                        # Opens a fuzzy picker of your top directories
```

> [!TIP]
> You don't need to change any habits. Just use `cd` normally — it's aliased to `z`, so zoxide is learning in the background. After a day or two, you'll be able to type `z proj` instead of `cd ~/long/path/to/Projects`.

### fzf — Fuzzy Finder

fzf provides instant fuzzy search powered by `fd` (for files) and your shell history.

| Shortcut | What It Does |
|----------|-------------|
| `Ctrl + R` | Search command **history**. Start typing any part of a past command. |
| `Ctrl + T` | Find a **file** by name. The full path is pasted onto your command line. |
| `Alt + C` | Find a **directory** and `cd` into it immediately. |

**Examples:**

```bash
# Ctrl+T example: find a config file
vim [Ctrl+T]               # Type "starship" → selects ~/.config/starship.toml
                            # Result: vim /Users/you/.config/starship.toml

# Ctrl+R example: find a past command
[Ctrl+R]                   # Type "docker" → shows all past docker commands
                            # Press Enter to execute, Tab to edit first
```

---

## 🛠️ Modern Tool Replacements

Every alias is defined in `~/.zshrc`. You can always access the originals with their full path.

### `ls` → `eza`

```bash
ls           # List with file-type icons and directory grouping
ll           # Long format with permissions, size, git status
la           # Same as ll but includes hidden files (dotfiles)

# Direct eza features
eza --tree   # Tree view of directory
eza -T -L 2  # Tree view, 2 levels deep
```

### `cat` → `bat`

```bash
cat file.py           # Syntax-highlighted output
bat file.py -l rust   # Force a specific language
bat -n file.py        # Show with line numbers
bat --diff file.py    # Show git diff inline
```

### `grep` → `ripgrep` (`rg`)

```bash
rg "TODO"              # Search all files recursively (respects .gitignore)
rg "function" -t js    # Only search JavaScript files
rg "error" -i          # Case-insensitive search
rg "pattern" -C 3      # Show 3 lines of context around matches
rg "import" --hidden   # Include hidden files/dirs
```

### `find` → `fd`

```bash
fd "*.ts"              # Find all TypeScript files
fd -e json             # Find by extension
fd -t d node_modules   # Find directories only
fd -t f -s "README"    # Find files, case-sensitive
fd "test" --exclude node_modules  # Exclude a directory
```

### `du` → `dust`

```bash
dust              # Visual bar chart of disk usage in current dir
dust -r           # Reverse sort (smallest first)
dust -n 15        # Show top 15 entries
dust ~/Projects   # Check a specific directory
```

### `top` → `btop`

```bash
btop              # Launch (press q to quit)
```
Inside btop: use arrow keys to navigate, `Tab` to switch between CPU/Memory/Network/Disk, `f` to filter processes, `k` to kill a process.

### Originals (If Needed)

| Original | Command |
|----------|---------|
| `cat` | `/bin/cat` |
| `ls` | `/bin/ls` |
| `find` | `/usr/bin/find` |
| `grep` | `/usr/bin/grep` |
| `du` | `/usr/bin/du` |
| `top` | `/usr/bin/top` |

---

## 🔀 Git Workflow

### Delta — Beautiful Diffs

[Delta](https://github.com/dandavella/delta) is auto-configured as your Git pager. Every `git diff`, `git log -p`, and `git show` now has syntax highlighting.

```bash
git diff              # Syntax-highlighted diff
git log -p -3         # Last 3 commits with highlighted patches
git show HEAD         # Show latest commit details
git stash show -p     # View stash contents
```

### lazygit — Full Git TUI

Launch with `lg`. This is an interactive Git interface that replaces most `git` commands.

| Key | Action |
|-----|--------|
| `1` - `5` | Switch panels (Status, Files, Branches, Commits, Stash) |
| `Space` | Stage / unstage file |
| `a` | Stage all files |
| `c` | Commit (opens editor inline) |
| `p` | Push |
| `P` (shift) | Pull |
| `b` | View branches |
| `Enter` | View file diffs |
| `/` | Filter |
| `?` | Full help |
| `q` | Quit |

### Recommended Git Workflow

```bash
# Quick commit flow
lg                    # Open lazygit
# Space to stage files, c to commit, p to push, q to quit

# Or traditional (now with delta highlighting)
git add -p            # Interactive staging with delta diffs
git commit -m "feat: add feature"
git push

# Quick status check
git diff              # See changes with syntax highlighting
git log --oneline -10 # Last 10 commits
```

---

## 📁 File Management with Yazi

[Yazi](https://yazi-rs.github.io) is a blazing-fast terminal file manager. Launch it with `y`.

### Navigation

| Key | Action |
|-----|--------|
| `↑/↓` or `k/j` | Move up/down |
| `→` or `Enter` | Open file / enter directory |
| `←` or `Backspace` | Go to parent directory |
| `g g` | Jump to top |
| `G` | Jump to bottom |
| `/` | Search in current directory |
| `z` | Jump to directory (powered by zoxide) |

### File Operations

| Key | Action |
|-----|--------|
| `Space` | Select / deselect file |
| `y` | Copy (yank) selected files |
| `x` | Cut selected files |
| `p` | Paste files |
| `d` | Move to trash |
| `D` | Permanently delete |
| `r` | Rename |
| `a` | Create new file |
| `A` | Create new directory |

### Viewing & Opening

| Key | Action |
|-----|--------|
| `Enter` | Open with default app |
| `Tab` | Toggle preview panel |
| `1`/`2`/`3` | Switch view layout |

### Quitting

Press `q` to quit. Your terminal will **stay in the last directory** you were browsing — no need to `cd` again.

---

## 🌟 Starship Prompt

A two-line [Starship](https://starship.rs) prompt: everything worth knowing on the first line, the prompt character alone on the second. Each segment has its own colour and Nerd Font icon. Colours are ANSI palette names rather than hex values, so they follow the terminal theme — Catppuccin Mocha in dark mode, Latte in light.

> [!NOTE]
> The icons below only render with a Nerd Font installed (including in this file). The installer ships JetBrains Mono Nerd Font.

A clean repo on `main`, in a pnpm project:

```
  ghostforge  main   20.20.0 󰏗 pnpm  1.2.3 󰁹 43%  12:30
◎
```

The same repo with work in progress, right after a command failed:

```
  ghostforge  feat/prompt-colors  1  2  1  1 +12 -3  20.20.0 󰏗 pnpm  5s  127 󰁹 43%  12:30
○
```

| Segment | Colour | Shows |
|---------|--------|-------|
| `` | grey | OS mark; starts the info line |
| ` ghostforge` | blue | Directory, cut to the repo root or the last 2 levels. `~` is home, `` means read-only |
| ` main` | purple | Git branch — always shown, `main` included. Detached HEAD shows ` <hash>` instead |
| `` | green | Working tree is clean: nothing staged, modified or untracked |
| ` 1  2  1` | per kind | Pending changes with counts: `` staged (green), `` modified (yellow), `` untracked (cyan), `` renamed (blue), `` deleted (red), `` conflicted (red), `` stashed (grey) |
| ` 1` / ` 1` | green / red | Commits ahead of / behind the upstream |
| `+12 -3` | green / red | Lines added / deleted versus `HEAD` |
| ` 20.20.0` | green | Node.js version. Turns **red** when `package.json` `engines.node` rejects the running version |
| `󰏗 pnpm` | cyan | Package manager, read from the lockfile: `󰏗 pnpm`, ` yarn` or ` npm`. Bun projects show ` <version>` in place of Node |
| ` 1.2.3` | purple | Version from `package.json` (public packages only) |
| ` 5s` | yellow | Duration of the last command (only if > 2s) |
| ` 127` | red | Exit code of the last command (only on failure) |
| `󰁹 43%` | by level | Battery, only below 70%: green, yellow below 50%, red below 20%. `󰂄` while charging |
| ` 12:30` | grey | Current time |
| `◎` / `○` | yellow / red | Prompt character: `◎` success, `○` last command failed |

### Modules Enabled

| Module | When It Shows |
|--------|--------------|
| **OS** | Always (`` on macOS) |
| **Username** | Only in SSH sessions or as root (` user`) |
| **Directory** | Always |
| **Git branch** | Inside any git repo, on every branch |
| **Git clean check** | Repo with nothing to commit |
| **Git status** | Staged, modified, untracked, renamed, deleted, conflicted or stashed changes, or a branch that is ahead/behind |
| **Git metrics** | Lines added/deleted in the working tree, right after git status |
| **Node.js** | When `package.json`, `.nvmrc`, `.node-version`, a lockfile or `node_modules` exists — except in Bun projects |
| **Bun** | When `bun.lock`, `bun.lockb` or `bunfig.toml` exists |
| **pnpm / yarn / npm** | When `pnpm-lock.yaml`, `yarn.lock` or `package-lock.json` exists |
| **Package** | When `package.json` (or `Cargo.toml`, `pyproject.toml`…) declares a version and the package is not private |
| **Python, Go, Rust, Ruby, Java, Lua, Swift, PHP, Kotlin, Dart** | In projects of that language, each with its own logo |
| **Docker / Terraform / gcloud** | When a Docker context, Terraform workspace or gcloud account is active |
| **Cmd duration** | When a command takes longer than 2 seconds |
| **Exit code** | When the last command failed |
| **Jobs** | When background jobs are running (` n`, on the prompt line) |
| **Sudo** | When sudo credentials are cached (``) |
| **Battery** | Below 70% |
| **Time** | Always (HH:MM format) |

### Testing a Change

`tests/test_prompt.sh` renders `configs/starship.toml` against throwaway repos — clean, dirty, ahead of upstream, and pnpm/yarn/npm/bun projects — and checks that every segment shows up exactly when it should. It never touches `~/.config`.

```bash
tests/test_prompt.sh
```

---

## ⚙️ Configuration Reference

### File Locations

| Config | Path | Purpose |
|--------|------|---------|
| Ghostty | `~/.config/ghostty/config` | Terminal appearance & keybindings |
| Starship | `~/.config/starship.toml` | Prompt modules & colors |
| Zsh | `~/.zshrc` | Shell aliases, plugins & tool init |

### Quick Edits

**Change transparency:**
```ini
# ~/.config/ghostty/config
background-opacity = 0.85   # Lower = more transparent
background-blur = 30        # Higher = more blur (needs opacity < 1.0)
```

**Change font size:**
```ini
# ~/.config/ghostty/config
font-size = 14              # Default is 13.5
```

**Force dark/light theme:**
```ini
# ~/.config/ghostty/config
theme = dark:Catppuccin Mocha    # Always dark
theme = light:Catppuccin Latte   # Always light
```

**Use neovim as editor** (if installed):
```bash
# ~/.zshrc  — change this line:
export EDITOR="nvim"
```

**Disable a Starship module:**
```toml
# ~/.config/starship.toml — add disabled = true
[battery]
disabled = true
```

---

## ❓ Troubleshooting & Known Issues

### Issues Found During Setup

| # | Issue | Resolution |
|---|-------|------------|
| 1 | Original guide said `Alt+Shift+D` for splits | Actual keybinding is **`Ctrl+Shift+D`** |
| 2 | Original guide said `Alt+Shift+Right` for right split | Actual keybinding is **`Ctrl+Shift+Right`** |
| 3 | `export EDITOR="nvim"` assumed neovim installed | Set to `vim`; change to `nvim` after installing |
| 4 | FZF init used `~/.fzf.zsh` (git-install path) | Fixed to `source <(fzf --zsh)` (Homebrew) |
| 5 | `alias cd='z'` overrides built-in `cd` | Use `builtin cd` when needed |
| 6 | Yazi's `ff()` used `cd` (hit the alias) | Fixed to use `builtin cd` |
| 7 | `shell-integration-features = all` invalid | Removed — shell integration is on by default |
| 8 | `close_split` not a valid Ghostty action | Changed to `close_surface` |

### Common Problems

**Icons not showing (boxes or question marks):**
> Make sure Ghostty is using the Nerd Font. Check `~/.config/ghostty/config`:
> ```ini
> font-family = "JetBrainsMono Nerd Font"
> ```
> Seeing boxes in **Terminal.app** or the **VS Code** terminal instead? Those use their own font settings — see [Matching Look in Terminal.app & VS Code](../README.md#️-matching-look-in-terminalapp--vs-code) in the README for drop-in configs.

**`cd` behaving differently than expected:**
> `cd` is aliased to `z` (zoxide). Use `builtin cd /exact/path` for traditional behavior.

**Scripts failing with `find` or `grep` errors:**
> The aliases override the originals. In scripts, use `/usr/bin/find` or `/usr/bin/grep`.

**Starship prompt not showing:**
> Ensure it's initialized in `.zshrc`:
> ```bash
> eval "$(starship init zsh)"
> ```

**Alt+C not working in Ghostty:**
> macOS may intercept `Alt` key. In Ghostty, `Alt` passes through by default. If it doesn't work, check **System Settings → Keyboard → Keyboard Shortcuts** for conflicts.
