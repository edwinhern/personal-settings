#!/usr/bin/env sh

set -eu

# check format Markdown and YAML files.
npx -y prettier --check --ignore-unknown \
  "**/*.md" \
  "**/*.yml"

printf "* %s\n" "Linting shell scripts..."

# Collect shell targets from scripts/ and .config/zsh/
SH_TARGETS=$(find scripts .config/zsh -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# check format Shell scripts (bash dialect covers posix + zsh constructs).
# shellcheck disable=SC2086
shfmt --language-dialect bash --indent 2 --diff ${SH_TARGETS}

# lint for errors in Shell scripts.
# shellcheck disable=SC2086
shellcheck --shell bash --external-sources ${SH_TARGETS}

printf "* %s\n" "All linting complete!"
