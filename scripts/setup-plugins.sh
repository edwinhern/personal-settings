#!/usr/bin/env sh

set -eu

# Read .plugin-versions and add each plugin to asdf
while read -r plugin url ref; do
  # Skip comments and empty lines
  case "$plugin" in
  "#"* | "") continue ;;
  esac

  printf "Adding plugin: %s from %s (ref: %s)\n" "$plugin" "$url" "$ref"
  asdf plugin add "$plugin" "$url" "$ref" || true
done <.plugin-versions

printf "Plugins setup complete!\n"
