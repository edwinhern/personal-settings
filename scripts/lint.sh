#!/usr/bin/env sh

set -eu

# check format Markdown and YAML files.
npx -y prettier --check --ignore-unknown \
  "**/*.md" \
  "**/*.yml"

printf "* %s\n" "Linting shell scripts..."

# check format Shell scripts in scripts/ directory.
shfmt --language-dialect posix --indent 2 --diff \
  ./scripts/*

# lint for errors in Shell scripts in scripts/ directory.
shellcheck --shell sh --external-sources \
  ./scripts/*

printf "* %s\n" "All linting complete!"
