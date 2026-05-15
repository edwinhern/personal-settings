#!/usr/bin/env sh
# @file lib/common/log.sh
# @brief Logging primitives for shell scripts. Pure POSIX shell, no Go
#        template syntax. Sourceable in tests; template-injected into
#        chezmoi run-scripts via chezmoi's `template` directive. See
#        usage examples in home/.chezmoiscripts/*.tmpl.
#
# @description
#   log_info   prints to stdout with no prefix; callers add their own tag if
#              they want one (e.g. "[apm] Installing...").
#   log_warn   prints to stderr with a "warn: " prefix; non-fatal anomalies.
#   log_error  prints to stderr with an "error: " prefix; pair with `exit 1`
#              for fatal conditions.

log_info() {
  printf '%s\n' "$*"
}

log_warn() {
  printf 'warn: %s\n' "$*" >&2
}

log_error() {
  printf 'error: %s\n' "$*" >&2
}
