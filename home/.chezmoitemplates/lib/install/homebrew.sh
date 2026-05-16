#!/usr/bin/env bash
# @file lib/install/homebrew.sh
# @brief Install Homebrew.
# @description
#   Installs Homebrew from the official installation script. This file is sourceable
#   from bats tests and injected into chezmoi run scripts via chezmoi template
#   rendering.
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

#
# @description Check if Homebrew is installed.
#
function is_homebrew_installed() {
  command -v brew >/dev/null 2>&1
}

#
# @description Install Homebrew.
#
function homebrew_install_main() {
  log_info "[homebrew] Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  log_info "[homebrew] Install complete."
}

#
# @description Run the Homebrew install flow.
#
function main() {
  if is_homebrew_installed; then
    log_info "[homebrew] Homebrew is already installed, skipping installation."
    return 0
  fi

  homebrew_install_main
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
