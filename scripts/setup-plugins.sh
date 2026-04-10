#!/usr/bin/env sh

set -eu

# Read .plugin-versions and add each plugin to asdf
while read -r plugin url ref; do
  # Skip comments and empty lines
  case "$plugin" in
    "#"* | "") continue ;;
  esac
  
  printf "Adding plugin: %s from %s\n" "$plugin" "$url"
  asdf plugin add "$plugin" "$url" || true
done < .plugin-versions

printf "Plugins setup complete!\n"
