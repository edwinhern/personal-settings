#!/usr/bin/env sh

set -eu

printf "* %s\n\n" "Formatting shell scripts..."

# Collect shell targets from scripts/ and home/dot_config/zsh/
SH_TARGETS=$(find scripts home/dot_config/zsh -type f \( -name '*.sh' -o -name '*.zsh' -o -name '.zshrc' \))

# shellcheck disable=SC2086
mise exec -- shfmt --language-dialect bash --find ${SH_TARGETS}
# shellcheck disable=SC2086
mise exec -- shfmt --language-dialect bash --indent 2 --write ${SH_TARGETS}

printf "\n* %s\n\n" "Formatting markdown and YAML..."

# format Markdown and YAML files.
mise exec -- prettier --write --ignore-unknown \
  "**/*.md" \
  "**/*.yml" \
  "**/*.yaml"

printf "\n* %s\n\n" "Formatting TOML..."

# format TOML files (skip *.tmpl — chezmoi templates contain Go template syntax).
TOML_TARGETS=$(find . -name '*.toml' -not -name '*.tmpl' -not -path './.git/*')
# shellcheck disable=SC2086
mise exec -- taplo fmt ${TOML_TARGETS}

printf "\n* %s\n" "Formatting complete!"
