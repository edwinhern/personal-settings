#!/usr/bin/env sh

set -eu

# Each tool below auto-discovers its config from the repo root:
# prettier reads .prettierrc and .prettierignore;
# shfmt reads .editorconfig (shell_variant = bash);
# the shell linter reads .shellcheckrc;
# taplo reads taplo.toml.

mise exec -- prettier --check .

# Collect shell targets for shellcheck + shfmt. Scope is kept narrow so
# untouched legacy scripts (e.g. statusline) are not pulled in implicitly.
SH_TARGETS=$(find scripts home/dot_config/zsh home/.chezmoitemplates .github/actions -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# shellcheck disable=SC2086
mise exec -- shellcheck ${SH_TARGETS}
# shellcheck disable=SC2086
mise exec -- shfmt --diff ${SH_TARGETS}

mise exec -- taplo fmt --check
