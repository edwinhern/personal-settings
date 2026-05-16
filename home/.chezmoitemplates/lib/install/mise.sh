#!/usr/bin/env bash
# @file lib/install/mise.sh
# @brief Install mise-managed tools.
# @description
#   Runs `mise install --yes` after chezmoi has rendered the user's mise
#   config. This file is sourceable from bats tests and injected into chezmoi
#   run scripts via chezmoi template rendering.

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

#
# @description Check if mise is installed.
#
function is_mise_installed() {
  command -v mise >/dev/null 2>&1
}

#
# @description Install tools declared in mise config.
#
function mise_install_main() {
  log_info "[mise] Installing mise tools..."
  mise install --yes
  log_info "[mise] Mise tools installed."
}

#
# @description Run the mise install flow.
#
function main() {
  if ! is_mise_installed; then
    log_error "[mise] mise not found. Ensure run_onchange_02_install-packages ran successfully."
    return 1
  fi

  mise_install_main
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
