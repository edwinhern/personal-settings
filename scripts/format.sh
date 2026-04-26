#!/usr/bin/env sh

set -eu

printf "* %s\n\n" "Formatting shell scripts..."

# Collect shell targets from scripts/ and home/dot_config/zsh/
SH_TARGETS=$(find scripts home/dot_config/zsh -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# shellcheck disable=SC2086
shfmt --language-dialect bash --find ${SH_TARGETS}
# shellcheck disable=SC2086
shfmt --language-dialect bash --indent 2 --write ${SH_TARGETS}

printf "\n* %s\n\n" "Formatting markdown and YAML..."

# format Markdown and YAML files.
npx -y prettier --write --ignore-unknown \
  "**/*.md" \
  "**/*.yml"

printf "\n* %s\n" "Formatting complete!"
