#!/usr/bin/env sh

set -eu

# check format Markdown and YAML files.
npx -y prettier --check --ignore-unknown \
  "**/*.md" \
  "**/*.yml"

printf "* %s\n" "Linting shell scripts..."

# Collect shell targets from scripts/ and home/dot_config/zsh/
SH_TARGETS=$(find scripts home/dot_config/zsh -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# check format Shell scripts (bash dialect covers posix + zsh constructs).
# shellcheck disable=SC2086
mise exec -- shfmt --language-dialect bash --indent 2 --diff ${SH_TARGETS}

# lint for errors in Shell scripts.
# shellcheck disable=SC2086
mise exec -- shellcheck --shell bash --external-sources ${SH_TARGETS}

printf "* %s\n" "Checking TOML formatting..."

# check TOML formatting (skip *.tmpl — chezmoi templates contain Go template syntax).
TOML_TARGETS=$(find . -name '*.toml' -not -name '*.tmpl' -not -path './.git/*')
# shellcheck disable=SC2086
mise exec -- taplo fmt --check ${TOML_TARGETS}

printf "* %s\n" "All linting complete!"
