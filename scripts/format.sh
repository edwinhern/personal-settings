#!/usr/bin/env sh

set -eu

printf "* %s\n\n" "Formatting shell scripts..."

# format Shell scripts in scripts/ directory.
shfmt --language-dialect posix --find \
  ./scripts/*
shfmt --language-dialect posix --indent 2 --write \
  ./scripts/*

printf "\n* %s\n\n" "Formatting markdown and YAML..."

# format Markdown and YAML files.
npx -y prettier --write --ignore-unknown \
  "**/*.md" \
  "**/*.yml"

printf "\n* %s\n" "Formatting complete!"
