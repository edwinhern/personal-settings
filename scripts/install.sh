#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from this dotfiles repo.
# Order: brew -> mise -> chezmoi (via mise) -> chezmoi apply -> mise install -> brew bundle.
# Idempotent: safe to re-run.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

step() {
  printf "\n==> %s\n" "$*"
}

# 1. Homebrew --------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for this shell (Apple Silicon path).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. mise ------------------------------------------------------------------
if ! command -v mise >/dev/null 2>&1; then
  step "Installing mise"
  brew install mise
fi

eval "$(mise activate bash --shims)"

# 3. chezmoi (ephemeral via mise; the managed config will pin it after apply)
step "Running chezmoi init --apply (will prompt for context on first run)"
mise x chezmoi@latest -- chezmoi init --apply --source "${REPO_ROOT}"

# 4. mise install ----------------------------------------------------------
step "Installing mise-managed runtimes"
mise install

# 5. brew bundle -----------------------------------------------------------
step "Installing apps via brew bundle"
brew bundle --file="${HOME}/.config/homebrew/Brewfile"

step "Done. Open a new shell to pick up ZDOTDIR/PATH changes."
