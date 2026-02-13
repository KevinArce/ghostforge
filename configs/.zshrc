# --- Environment -------------------------------------------------------------
if [ -d /opt/homebrew/bin ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
export EDITOR="vim"  # Changed from nvim (not installed); update to "nvim" if you install it
export LANG="en_US.UTF-8"

# --- History (Optimized) -----------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY           # Share history between Ghostty tabs
setopt INC_APPEND_HISTORY      # Write immediately
setopt HIST_IGNORE_ALL_DUPS    # No duplicates

# --- FZF & Navigation (The "Brain") ------------------------------------------
# Use 'fd' instead of 'find' for speed
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Initialize FZF (Homebrew install method)
source <(fzf --zsh)

# Initialize Zoxide (Smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias c='z'
  alias cd='z'
  alias cdi='zi' # Interactive jump
fi

# Yazi (File Manager) Integration with directory persistence
function ff() {
	local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias y='ff'

# --- Aliases (Modern Tools) --------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --git --icons --group-directories-first'
alias la='eza -lha --git --icons --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias find='fd'
alias du='dust'
alias top='btop'
alias lg='lazygit'

# --- Git Beautification ------------------------------------------------------
if command -v delta >/dev/null 2>&1; then
  git config --global core.pager "delta"
  git config --global interactive.diffFilter "delta --color-only"
fi

# --- Plugins & Prompt --------------------------------------------------------
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- NVM (Node Version Manager) — preserved from original config -------------
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# --- OpenClaw Completion — preserved from original config --------------------
source <(openclaw completion --shell zsh)
