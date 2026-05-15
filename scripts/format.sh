#!/usr/bin/env sh

set -eu

# Each tool below auto-discovers its config from the repo root:
# prettier reads .prettierrc and .prettierignore;
# shfmt reads .editorconfig (shell_variant = bash);
# taplo reads taplo.toml.

# Collect shell targets for shfmt. Scope mirrors scripts/lint.sh.
SH_TARGETS=$(find scripts home/dot_config/zsh home/.chezmoitemplates .github/actions -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# shellcheck disable=SC2086
mise exec -- shfmt --write ${SH_TARGETS}

mise exec -- prettier --write .

mise exec -- taplo fmt
