# --- Environment -------------------------------------------------------------
if [ -z "$HOMEBREW_PREFIX" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
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

# Initialize FZF (Homebrew static path for instant sourcing)
if [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh 2>/dev/null
fi
if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh 2>/dev/null
elif command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

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

# --- Plugins & Prompt --------------------------------------------------------
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- NVM (Node Version Manager) — Lazy Loaded --------------------------------
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx yarn pnpm _load_nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }
yarn() { _load_nvm; yarn "$@"; }
pnpm() { _load_nvm; pnpm "$@"; }

# --- OpenClaw Completion — Lazy Loaded --------------------------------------
if command -v openclaw >/dev/null 2>&1; then
  _load_openclaw() {
    unset -f openclaw _load_openclaw
    source <(openclaw completion --shell zsh 2>/dev/null)
    openclaw "$@"
  }
  openclaw() { _load_openclaw "$@"; }
fi
