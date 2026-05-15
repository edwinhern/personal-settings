#!/usr/bin/env sh

set -eu

printf "* %s\n\n" "Validating APM packages..."

found=0

# Primary: home/dot_config/apm/ (chezmoi-managed, template file)
# apm.yml.tmpl is rendered by chezmoi at apply time — validate the rendered copy
# if it exists (i.e. chezmoi has been applied), otherwise dry-run from source.
if [ -f "$HOME/.config/apm/apm.yml" ]; then
  printf "Validating rendered APM config (~/.config/apm/apm.yml)...\n"
  (cd "$HOME/.config/apm" && apm install --dry-run --runtime claude)
  printf "✓ APM config validated successfully\n\n"
  found=$((found + 1))
elif [ -f "home/dot_config/apm/apm.yml.tmpl" ]; then
  printf "[i] apm.yml.tmpl found but not yet rendered (chezmoi not applied).\n"
  printf "[i] APM validation skipped — run 'chezmoi apply' first, or check CI dry-run.\n\n"
  found=$((found + 1))
fi

if [ "$found" -eq 0 ]; then
  printf "[i] No APM packages found to compile.\n"
fi

printf "* %s\n" "Done."
