#!/bin/bash
# ============================================================================
#  🔮 Ghostty Terminal Setup — Installer
#  A one-command setup for a fast, beautiful, keyboard-centric terminal.
#
#  Usage:  chmod +x install.sh && ./install.sh
#  Re-run: Safe to run multiple times (idempotent).
# ============================================================================

set -euo pipefail

# --- Colors & Helpers --------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠️${NC}  $1"; }
error()   { echo -e "${RED}❌${NC} $1"; }
step()    { echo -e "\n${PURPLE}${BOLD}$1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Header ------------------------------------------------------------------
echo ""
echo -e "${PURPLE}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║        🔮 Ghostty Terminal Setup         ║"
echo "  ║   Fast • Beautiful • Keyboard-Centric    ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# --- 1. Preflight Check ------------------------------------------------------
step "1/6 — Preflight Check"

if ! command -v brew &>/dev/null; then
  error "Homebrew not found. Install it first:"
  echo '       /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
success "Homebrew $(brew --version | head -1 | awk '{print $2}')"

# Detect architecture
if [ -d /opt/homebrew ]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi
info "Homebrew prefix: $BREW_PREFIX"

# --- 2. Install Terminal & Font -----------------------------------------------
step "2/6 — Installing Ghostty & Nerd Font"

install_cask() {
  if brew list --cask "$1" &>/dev/null; then
    success "$1 (already installed)"
  else
    info "Installing $1..."
    brew install --cask "$1" && success "$1" || warn "$1 install failed (may already exist)"
  fi
}

install_cask "ghostty"
install_cask "font-jetbrains-mono-nerd-font"

# --- 3. Install Shell Enhancements -------------------------------------------
step "3/6 — Installing Shell Enhancements"

SHELL_PKGS=(starship zoxide fzf zsh-autosuggestions zsh-syntax-highlighting)
for pkg in "${SHELL_PKGS[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    success "$pkg (already installed)"
  else
    info "Installing $pkg..."
    brew install "$pkg" && success "$pkg" || warn "$pkg install failed"
  fi
done

# --- 4. Install Modern Unix Tools --------------------------------------------
step "4/6 — Installing Modern Unix Tools"

TOOL_PKGS=(bat eza fd ripgrep dust btop yazi lazygit git-delta tmux)
for pkg in "${TOOL_PKGS[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    success "$pkg (already installed)"
  else
    info "Installing $pkg..."
    brew install "$pkg" && success "$pkg" || warn "$pkg install failed"
  fi
done

# --- 5. Deploy Configuration Files -------------------------------------------
step "5/6 — Deploying Configuration Files"

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
  BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$HOME/.zshrc" "$BACKUP"
  info "Backed up existing .zshrc → $(basename "$BACKUP")"
fi

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
cp "$SCRIPT_DIR/configs/ghostty_config" "$HOME/.config/ghostty/config"
success "Ghostty  → ~/.config/ghostty/config"

# Starship config
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
success "Starship → ~/.config/starship.toml"

# Zsh config
cp "$SCRIPT_DIR/configs/.zshrc" "$HOME/.zshrc"
success "Zsh      → ~/.zshrc"

# --- 6. Set Ghostty as Default Handler ----------------------------------------
step "6/6 — Setting Defaults"

# Install duti for file associations
if ! command -v duti &>/dev/null; then
  info "Installing duti (file association tool)..."
  brew install duti &>/dev/null && success "duti installed" || warn "duti install failed"
fi

if command -v duti &>/dev/null; then
  for ext in sh command zsh bash; do
    duti -s com.mitchellh.ghostty ".$ext" all 2>/dev/null
  done
  success "Ghostty set as default for .sh .command .zsh .bash"
else
  warn "Skipped file associations (duti not available)"
fi

# Configure git to use delta
if command -v delta &>/dev/null; then
  git config --global core.pager "delta"
  git config --global interactive.diffFilter "delta --color-only"
  success "Git configured to use delta for diffs"
fi

# --- Done! --------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║           🎉 Setup Complete!             ║"
echo "  ╠══════════════════════════════════════════╣"
echo "  ║                                          ║"
echo "  ║  1. Open Ghostty from /Applications      ║"
echo "  ║  2. Try: ls, ll, cat <file>              ║"
echo "  ║  3. Try: Ctrl+Shift+D (split down)       ║"
echo "  ║  4. Try: Alt+H/J/K/L (navigate splits)   ║"
echo "  ║  5. Try: Ctrl+R (fuzzy history search)   ║"
echo "  ║                                          ║"
echo "  ║  📖 Full guide: docs/USER_GUIDE.md       ║"
echo "  ║                                          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"
