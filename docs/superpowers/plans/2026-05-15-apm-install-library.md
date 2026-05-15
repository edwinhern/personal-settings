# APM Install Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract APM install logic from the chezmoi run script into a sourceable and directly testable bash library under `home/.chezmoitemplates/lib/install/`.

**Architecture:** `home/.chezmoitemplates/lib/install/apm.sh` is the source of truth and follows the executable bash script shape with `apm_install_main`, `main`, and a `BASH_SOURCE` guard. The chezmoi run script injects `lib/common/log.sh` and `lib/install/apm.sh` with `{{ template }}` and keeps content-hash trigger comments. Bats tests source the library directly and use a fake `apm` executable on `PATH`.

**Tech Stack:** Chezmoi templates, bash, bats-core, bats-support, bats-assert, mise.

---

## File Structure

- Create `home/.chezmoitemplates/lib/install/apm.sh`: bash library for APM install behavior.
- Create `tests/unit/lib/install/apm.bats`: unit tests that source `apm.sh` and fake the `apm` binary.
- Modify `home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl`: replace inline shell logic with library includes and keep hash-trigger comments.
- Modify `docs/superpowers/specs/2026-05-15-ci-refactor-design.md`: record the final APM library shape.

### Task 1: Add APM Install Library Tests

**Files:**

- Create: `tests/unit/lib/install/apm.bats`
- Read: `tests/test_helpers/load.bash`

- [ ] **Step 1: Write the failing tests**

Create `tests/unit/lib/install/apm.bats` with tests that source `home/.chezmoitemplates/lib/common/log.sh`, source `home/.chezmoitemplates/lib/install/apm.sh`, put a fake `apm` executable on `PATH`, call `apm_install_main`, and assert `apm install --global` was called.

- [ ] **Step 2: Run tests and verify they fail because the library is missing**

Run: `mise exec -- bats tests/unit/lib/install/apm.bats`

Expected: FAIL because `home/.chezmoitemplates/lib/install/apm.sh` does not exist.

### Task 2: Implement APM Install Library

**Files:**

- Create: `home/.chezmoitemplates/lib/install/apm.sh`
- Test: `tests/unit/lib/install/apm.bats`

- [ ] **Step 1: Create the library**

Create `home/.chezmoitemplates/lib/install/apm.sh`:

```bash
#!/usr/bin/env bash
# @file lib/install/apm.sh
# @brief Install APM-managed agent files from the user-scope APM project.
# @description
#   Runs `apm install --global` from `${HOME}/.apm`. This file is sourceable
#   from bats tests and injected into chezmoi run scripts via chezmoi template
#   rendering.

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

#
# @description Install APM dependencies from `${HOME}/.apm/apm.yml`.
#
function apm_install_main() {
  log_info "[apm] Installing globally from ~/.apm/apm.yml..."
  cd "${HOME}/.apm"

  apm install --global || log_warn "[apm] apm install exited with errors (likely MCP token prompts in non-interactive shell)"

  log_info "[apm] Install complete."
}

#
# @description Run the APM install flow.
#
function main() {
  apm_install_main
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
```

- [ ] **Step 2: Run tests and verify they pass**

Run: `mise exec -- bats tests/unit/lib/install/apm.bats`

Expected: PASS.

### Task 3: Refactor Chezmoi APM Run Script

**Files:**

- Modify: `home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl`
- Test: `home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl`

- [ ] **Step 1: Replace inline APM shell logic with template includes**

Update `home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl` so it keeps the Darwin gate around the library includes:

```go-template
{{ if eq .chezmoi.os "darwin" }}
{{ template "lib/common/log.sh" . }}
{{ template "lib/install/apm.sh" . }}
{{ end }}
```

Keep the existing content-hash trigger comments in the file before the conditional includes.

- [ ] **Step 2: Render the template and verify bash syntax**

Run: `mise exec -- chezmoi execute-template --source home < home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl | bash -n`

Expected: exit code 0.

### Task 4: Update Spec For Final Library Shape

**Files:**

- Modify: `docs/superpowers/specs/2026-05-15-ci-refactor-design.md`

- [ ] **Step 1: Update current PR checklist**

Add these checked items under the current PR section:

```markdown
- [x] Add `home/.chezmoitemplates/lib/install/apm.sh` with executable bash script shape and `apm_install_main`.
- [x] Refactor `run_onchange_06_install-apm.sh.tmpl` to inject `lib/common/log.sh` and `lib/install/apm.sh`.
- [x] Add `tests/unit/lib/install/apm.bats` with fake `apm` on `PATH`.
```

### Task 5: Final Verification

**Files:**

- Verify: all changed files

- [ ] **Step 1: Run shell library tests**

Run: `mise exec -- bats tests/unit/lib/common/log.bats tests/unit/lib/install/apm.bats`

Expected: PASS.

- [ ] **Step 2: Run all tests**

Run: `make test`

Expected: PASS.

- [ ] **Step 3: Run lint**

Run: `make lint`

Expected: PASS.

- [ ] **Step 4: Check git diff**

Run: `git diff --check && git status --short --branch`

Expected: no whitespace errors; branch shows only intended changed files.
