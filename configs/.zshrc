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
# `cd='z'` is NOT set here -- it lives in the interactive-only alias block below.
# See the comment there for why.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias c='z'
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
# Aliases that shadow a real binary are confined to a real terminal, because the
# replacements are not drop-in flag-compatible: eza rejects `ls -t`, and rg reads
# `-E` as --encoding rather than --extended-regexp. Leaking those into scripts or
# editor/agent tooling breaks otherwise-valid commands.
#
# `cd='z'` is here for a related reason. Tooling that snapshots this file and
# replays it into a non-interactive shell restores aliases but NOT the
# chpwd_functions array that zoxide's hook lives in. A leaked `cd` alias then
# routes every scripted cd through zoxide, which trips its "configuration issue"
# doctor warning on each call. Note that zoxide's own suggestion -- move the init
# to the end of the file -- does not help: the array is dropped regardless.
#
# The `-t 0` test is load-bearing. `-o interactive` alone is NOT enough, because
# such tooling typically runs `zsh -i -c ...`, which sets both `interactive` and
# `zle` yet never has a tty on stdin. Only `-t 0` distinguishes the two.
if [[ -o interactive && -t 0 ]]; then
  alias cd='z'
  alias ls='eza --icons --group-directories-first'
  alias cat='bat --style=plain --paging=never'
  alias grep='rg'
  alias find='fd'
  alias du='dust'
  alias top='btop'
fi

# Safe in any shell: these shadow nothing.
alias ll='eza -lh --git --icons --group-directories-first'
alias la='eza -lha --git --icons --group-directories-first'
alias lg='lazygit'

# --- Plugins & Prompt --------------------------------------------------------
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- NVM (Node Version Manager) — Lazy Loaded --------------------------------
# Probes both supported layouts. The Homebrew formula keeps nvm.sh under
# $HOMEBREW_PREFIX/opt/nvm, while the upstream install script puts it in
# $NVM_DIR (~/.nvm) and installs no formula at all. Hardcoding only the Homebrew
# path leaves node/npm/nvm completely unavailable on a git-installed nvm.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx yarn pnpm _load_nvm
  local _brew="${HOMEBREW_PREFIX:-/opt/homebrew}"
  if [ -s "$_brew/opt/nvm/nvm.sh" ]; then
    \. "$_brew/opt/nvm/nvm.sh"
    [ -s "$_brew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$_brew/opt/nvm/etc/bash_completion.d/nvm"
  elif [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  else
    echo "nvm: not found in $_brew/opt/nvm or $NVM_DIR" >&2
    return 1
  fi
  # Explicit: the optional completion `[ -s ... ] &&` above is the last statement
  # in each branch, so without this a missing completion file would report
  # failure even though nvm.sh loaded fine.
  return 0
}

# Each wrapper loads nvm once, then re-dispatches to the real command. Guarding
# on `&&` keeps a failed load from following up with a confusing
# "command not found", since _load_nvm has already removed these wrappers.
nvm()  { _load_nvm && nvm "$@"; }
node() { _load_nvm && node "$@"; }
npm()  { _load_nvm && npm "$@"; }
npx()  { _load_nvm && npx "$@"; }
yarn() { _load_nvm && yarn "$@"; }
pnpm() { _load_nvm && pnpm "$@"; }

# --- OpenClaw Completion — Lazy Loaded --------------------------------------
if command -v openclaw >/dev/null 2>&1; then
  _load_openclaw() {
    unset -f openclaw _load_openclaw
    source <(openclaw completion --shell zsh 2>/dev/null)
    openclaw "$@"
  }
  openclaw() { _load_openclaw "$@"; }
fi
