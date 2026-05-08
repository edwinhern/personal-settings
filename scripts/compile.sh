#!/usr/bin/env sh

set -eu

printf "* %s\n\n" "Compiling APM packages..."

# Find all directories in packages/ that contain apm.yml
for package_dir in packages/*/; do
  if [ -f "${package_dir}apm.yml" ]; then
    package_name=$(basename "$package_dir")
    printf "Compiling package: %s\n" "$package_name"

    # Change to package directory and run apm compile --validate
    (cd "$package_dir" && apm compile --validate)

    printf "✓ %s compiled successfully\n\n" "$package_name"
  fi
done

printf "* %s\n" "All packages compiled!"
