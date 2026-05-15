# CI Refactor + Shell Testing Design

**Status:** PR #10 merged. Bats framework bootstrap is on `main`; Section 3 is now designed for the next CI refactor slice.

**Branch:** `main`

**PR:** [#10 Bootstrap bats framework for shell testing](https://github.com/edwinhern/dotfiles/pull/10)

**Merged PR #10 scope:** Added mise-pinned bats-core, vendored bats companion libraries, statusline fixtures, `tests/unit/statusline.bats`, and Make targets for `test`, `test-unit`, and `test-template`. `make check` now includes bats tests.

**Reference:** [shunk031/dotfiles](https://github.com/shunk031/dotfiles) — pattern source.

## Context

Current `.github/workflows/ci.yaml` has accumulated friction:

1. Duplicated chezmoi-config stub heredoc across `validate_apm` and `chezmoi_dry_run` jobs.
2. Inline `cp` plumbing in `validate_apm` re-implements parts of `chezmoi apply` manually.
3. No caching of mise/chezmoi/APM binaries — every CI run re-downloads via `curl`.
4. One monolithic workflow with four jobs of mixed concerns.
5. Ad-hoc `curl | sh` installs of chezmoi and APM repeated across jobs.

Resolved in PR #10: `mise.toml` now pins the shell and agent toolchain, including APM.

**Primary goal:** maintainability / best practices. Secondary goal: better coverage via shell-level unit tests. Speed is fine as-is.

## Decisions made so far

### 1. Library structure (Approach 1 — approved)

Reusable shell snippets live in `home/.chezmoitemplates/` so chezmoi can inject them into `.chezmoiscripts/` via `{{ template "..." . }}`. Files are pure shell (no Go template syntax), making them sourceable and testable in isolation.

```
home/.chezmoitemplates/lib/
├── common/                       # OS-agnostic helpers
│   ├── log.sh                    # log_info, log_error, log_warn
│   ├── error.sh                  # die, retry, with_timeout
│   └── os-detect.sh              # is_darwin, is_linux, has_command
├── darwin/                       # macOS-specific
│   └── homebrew.sh               # brew_install_if_missing
└── install/                      # cross-cutting install routines
    ├── apm.sh                    # apm_install_main, apm_install_with_retry
    └── chezmoi.sh                # chezmoi_install_if_missing
```

Consuming `.chezmoiscripts/*.tmpl` files pull in lib content via:

```go-template
{{ template "lib/common/log.sh" . }}
{{ template "lib/install/apm.sh" . }}
```

**Rationale:** mirrors chezmoi's own `.chezmoiscripts/{darwin,linux,windows}/` convention; OS separation is forward-looking even though only darwin exists today; pure-shell library files are unit-testable.

### 2. Testing setup (companion libs included)

**Toolchain:**

- bats-core pinned via `mise.toml` (alongside APM, shellcheck, shfmt, taplo, and prettier).
- `bats-support`, `bats-assert`, `bats-file` vendored under `tests/test_helpers/`. Small (~100 KB total), stable, removes network dependency for tests.

**Layout:**

```
mise.toml                         # pins shell and agent toolchain versions

tests/
├── test_helpers/
│   ├── bats-support/             # vendored, ~50 KB
│   ├── bats-assert/              # ~30 KB
│   ├── bats-file/                # ~20 KB
│   └── load.bash                 # single loader: `load test_helpers/load.bash`
├── unit/
│   ├── lib/
│   │   ├── common/               # mirrors home/.chezmoitemplates/lib/common/
│   │   │   ├── log.bats
│   │   │   ├── error.bats
│   │   │   └── os-detect.bats
│   │   ├── darwin/
│   │   │   └── homebrew.bats
│   │   └── install/
│   │       ├── apm.bats
│   │       └── chezmoi.bats
│   └── statusline.bats           # tests for home/dot_claude/statusline-command.sh
├── template/                     # chezmoi execute-template assertions
│   ├── apm-yml-personal.bats     # work=false rendering
│   ├── apm-yml-work.bats         # work=true rendering
│   └── install-apm-script.bats   # renders run_onchange_06_install-apm.sh.tmpl
├── fixtures/
│   ├── statusline/
│   │   ├── full-payload.json     # mock JSON used in earlier manual testing
│   │   ├── minimal.json
│   │   └── worktree.json
│   └── chezmoi/
│       └── stub-config-personal.yaml
└── helpers/
    └── (repo-specific helpers, e.g. `chezmoi.bash`)
```

**Make targets:**

```makefile
.PHONY: test test-unit test-template
test:          ## Run all bats tests
	mise exec -- bats --recursive tests/unit tests/template
test-unit:     ## Unit tests only (fast iteration)
	mise exec -- bats --recursive tests/unit
test-template: ## Template rendering tests only
	mise exec -- bats --recursive tests/template
```

**`tests/test_helpers/load.bash`:**

```bash
load 'bats-support/load'
load 'bats-assert/load'
load 'bats-file/load'

DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
export DOTFILES_ROOT
```

**Test files use:**

```bash
load '../test_helpers/load.bash'

@test "renders full statusline payload" {
  run bash "$DOTFILES_ROOT/home/dot_claude/statusline-command.sh" \
    < "$DOTFILES_ROOT/tests/fixtures/statusline/full-payload.json"
  assert_success
  assert_output --partial '🤖 Opus 4.7'
  assert_output --partial '🧠 17%'
}
```

### 3. `mise.toml` (landed in PR #10)

Pin shell and agent toolchain so CI and local development agree:

```toml
[tools]
"github:microsoft/apm" = "0.13.0"
bats = "1.13.0"
prettier = "3.8.3"
shellcheck = "0.11.0"
shfmt = "3.13.1"
taplo = "0.10.0"
```

`mise.toml` is the source of truth for APM versioning in CI. Workflow YAML should not hardcode `apm-version` unless the repo intentionally adopts an APM Action feature that requires it.

## Patterns to study from shunk031/dotfiles

Resume by reading these in their repo:

1. **`tests/install/common/*.bats`** — see actual test code style for OS-segmented suites. We haven't viewed these yet.
2. **`.github/workflows/test.yaml`** — the `changes` job uses `git diff --name-only` against base ref to set `should_test=true/false`, gating the heavier test matrix. Worth borrowing.
3. **Their `Makefile` test wiring** — fully view how bats gets invoked across local + CI + docker.
4. **`bats_load_library` mechanism** — how shunk031 loads companion libs (vs our vendoring approach). May simplify if mise can install bats-assert too.

## Section 3 - CI workflow refactor design

### Scope for next PR

Keep `.github/workflows/ci.yaml` as a single workflow for the next slice. The next PR should reduce duplicated setup and make CI use the same tool versions as local development. Do not split workflows or add changes gating yet; those are easier to reason about after the repeated setup is extracted.

### Toolchain setup

Use `jdx/mise-action@v4` as the CI toolchain entrypoint and run APM through mise:

```yaml
- uses: jdx/mise-action@v4

- name: Dry-run apm install
  run: mise exec -- apm install --dry-run --global
```

`mise.toml` pins APM as `"github:microsoft/apm" = "0.13.0"`, so CI should not duplicate that version in workflow YAML.

### APM Action decision

Do not use `microsoft/apm-action@v1` in the next slice. The official action is valuable, but this repo already gets version control from `mise.toml` and currently has no need for the action-specific features.

Use `microsoft/apm-action@v1` later if one of these becomes part of the CI design:

- SARIF output via `audit-report` and GitHub Code Scanning.
- Pack/restore workflows for sharing agent primitives across jobs.
- GitHub token forwarding for private or cross-org APM dependencies.
- APM bundle restore mode.

If the action is adopted later, decide first how to avoid version drift between `mise.toml` and the action's `apm-version` input.

### Chezmoi config setup

Extract the duplicated chezmoi config heredoc from `validate_apm` and `chezmoi_dry_run` into one composite action:

```
.github/actions/write-chezmoi-config/action.yml
```

Inputs:

- `context`: `personal` or `work`.

Behavior:

- Writes `$HOME/.config/chezmoi/chezmoi.yaml`.
- Sets `personal` and `work` booleans from the `context` input.
- Keeps the same CI stub values for hostname, git identity, and Atlassian resource URL.

This is the highest-value extraction because it removes repeated YAML while keeping job behavior unchanged.

### Chezmoi install setup

Keep manual chezmoi install for the next PR unless it becomes noisy during implementation. A separate `.github/actions/setup-chezmoi/` action can follow if the install remains repeated after the config extraction.

### APM validation

Keep the current rendered APM project shape for now:

1. Render `home/dot_apm/apm.yml.tmpl` into `$HOME/.apm/apm.yml`.
2. Copy `home/dot_apm/apm.lock.yaml` into `$HOME/.apm/apm.lock.yaml`.
3. Copy `home/dot_apm/dot_apm` into `$HOME/.apm/.apm`.
4. Run `mise exec -- apm install --dry-run --global` from `$HOME/.apm`.

Add baseline audit in the same job after rendering the project. Because this repo validates a user-scope `$HOME/.apm` project, audit should run against a scratch local project copied from the rendered files:

```yaml
- name: Audit APM project
  run: |
    apm_project="$(mktemp -d)"
    cp "$HOME/.apm/apm.yml" "$apm_project/apm.yml"
    cp "$HOME/.apm/apm.lock.yaml" "$apm_project/apm.lock.yaml"
    cp -r "$HOME/.apm/.apm" "$apm_project/.apm"
    mise exec -- sh -c "cd \"${apm_project}\" && apm install && apm audit --ci --no-drift --no-policy"
```

Keep `apm install --dry-run --global` because it validates the user-scope install path this dotfiles repo actually uses. The scratch audit provides lockfile and content checks, but uses `--no-drift` because full drift replay currently reports local included files as orphaned after APM integration. It also uses `--no-policy` because org policy governance is deferred.

### Bats test job

Add a dedicated CI job that runs the bats suite:

```yaml
test:
  name: Run bats tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v6
    - uses: jdx/mise-action@v4
    - run: make test
```

Keep `make check` as the local all-in-one command. CI should run `make lint`, APM validation, chezmoi dry-run, actionlint, and `make test` as separate jobs so failures point to the right concern.

### Deferred CI design

- Split `ci.yaml` into `lint.yaml`, `validate.yaml`, and `test.yaml` only after the setup duplication is gone.
- Add changes gating only after the workflow shape is smaller. Candidate skip rules: docs-only changes can skip APM and chezmoi dry-runs, but should still run markdown lint.
- Add caching only after measuring repeated setup time. Candidate caches: mise tools and APM modules.
- Add APM SARIF or org policy checks only after deciding whether this repo needs Code Scanning alerts or an `apm-policy.yml` governance layer.

## Open design questions (deferred)

### Section 4 — CLAUDE.md documentation update

Capture the new pattern as a documented convention:

- `.chezmoitemplates/lib/` for reusable shell snippets.
- `tests/` for bats unit + template tests.
- `make test` / `make test-unit` / `make test-template` workflow.
- Pure-shell rule (no Go template syntax in lib files).

## Migration plan

### PR #10 - bats framework bootstrap (merged)

- [x] Add `mise.toml` pinning current toolchain versions, including APM and bats-core.
- [x] Vendor `bats-support`, `bats-assert`, and `bats-file` under `tests/test_helpers/`.
- [x] Add `tests/test_helpers/load.bash`.
- [x] Add statusline fixtures under `tests/fixtures/statusline/`.
- [x] Add `make test`, `make test-unit`, and `make test-template` targets.
- [x] Add the first bats test suite: `tests/unit/statusline.bats`.
- [x] Include bats tests in `make check`.
- [x] Open PR #10 against `main` from `feat/ci-bats`.
- [x] Confirm PR #10 CI is green.
- [x] Merge PR #10 into `main`.

### Next PR - CI setup refactor

- [ ] Add `.github/actions/write-chezmoi-config/action.yml` with a `context` input.
- [ ] Replace duplicated chezmoi config heredocs in `validate_apm` and `chezmoi_dry_run`.
- [ ] Remove manual APM `curl` install from CI.
- [ ] Run APM commands through mise so `mise.toml` remains the version source of truth.
- [ ] Keep rendered `$HOME/.apm` project setup unchanged.
- [ ] Keep `apm install --dry-run --global` for the initial refactor.
- [ ] Add baseline `apm audit --ci` after the rendered APM project is prepared.
- [ ] Add a dedicated `test` job that runs `make test`.
- [ ] Verify the full workflow stays green for personal and work contexts.

### Later PRs

- [ ] Read `tests/install/common/*.bats` from shunk031/dotfiles for concrete test style.
- [ ] Read `.github/workflows/test.yaml` in full from shunk031/dotfiles.
- [ ] Read shunk031's Makefile test wiring in full.
- [ ] Verify whether `bats_load_library` or mise can replace vendoring of bats-assert/file/support in a future PR.
- [ ] Design Section 4: CLAUDE.md documentation update.
- [ ] Decide whether APM Action features are needed: SARIF, pack/restore, token forwarding, or bundle restore.
- [ ] Decide whether this repo needs `apm audit --ci --policy org` and an `apm-policy.yml` governance layer.
- [ ] Extract reusable shell code from `06_install-apm.sh.tmpl` into `home/.chezmoitemplates/lib/`.
- [ ] Add bats unit tests for extracted shell libraries.
- [ ] Add template rendering tests for chezmoi/APM outputs.
- [ ] Split CI workflows or add changes gating after setup duplication is removed.
- [ ] Add caching after measuring repeated setup time.
- [ ] Self-review the updated spec before each implementation PR.
- [ ] User reviews spec before the next migration slice.
- [ ] Hand off the next implementation slice to `writing-plans` skill.
