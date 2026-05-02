#!/bin/sh
# install.sh
# Bootstrap script for a fresh macOS machine.
# Installs Chezmoi if absent, then hands off to chezmoi init --apply.
# Chezmoi run_once_ and run_onchange_ scripts handle everything from there.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/edwinhern/dotfiles/main/scripts/install.sh | sh
#   — or —
#   ./scripts/install.sh  (from a local clone)

set -e

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"

  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# init + apply in one shot.
# Chezmoi will prompt for git.name, git.email, and context if hostname is unrecognized.
exec "$chezmoi" init --apply "gh:edwinhern/dotfiles"
