# CI Refactor + Shell Testing Design

**Status:** PR #10 open for first migration slice. Bats framework bootstrap is implemented and CI is green.

**Branch:** `feat/ci-bats`

**PR:** [#10 Bootstrap bats framework for shell testing](https://github.com/edwinhern/dotfiles/pull/10)

**Current PR scope:** Adds mise-pinned bats-core, vendored bats companion libraries, statusline fixtures, `tests/unit/statusline.bats`, and Make targets for `test`, `test-unit`, and `test-template`. `make check` now includes bats tests.

**Reference:** [shunk031/dotfiles](https://github.com/shunk031/dotfiles) — pattern source.

## Context

Current `.github/workflows/ci.yaml` has accumulated friction:

1. Duplicated chezmoi-config stub heredoc across `validate_apm` and `chezmoi_dry_run` jobs.
2. Inline `cp` plumbing in `validate_apm` re-implements parts of `chezmoi apply` manually.
3. No caching of mise/chezmoi/APM binaries — every CI run re-downloads via `curl`.
4. One monolithic workflow with four jobs of mixed concerns.
5. Ad-hoc `curl | sh` installs of chezmoi and APM repeated across jobs.

Secondary friction: the repo has no `.mise.toml` or `.tool-versions`, so toolchain versions in CI float to whatever mise's registry defaults to.

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

- bats-core pinned via `.mise.toml` (alongside existing shellcheck/shfmt/taplo/prettier).
- `bats-support`, `bats-assert`, `bats-file` vendored under `tests/test_helpers/`. Small (~100 KB total), stable, removes network dependency for tests.

**Layout:**

```
.mise.toml                        # NEW — pins all shell toolchain versions

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

### 3. `.mise.toml` (NEW — required by testing setup)

Pin all shell toolchain so CI and local development agree:

```toml
[tools]
bats        = "1.11.0"
shellcheck  = "0.10.0"
shfmt       = "3.10.0"
taplo       = "0.9.3"
node        = "lts"
prettier    = "3.3.3"
```

Exact versions TBD — first commit pins to whatever is currently installed locally.

## Patterns to study from shunk031/dotfiles

Resume by reading these in their repo:

1. **`tests/install/common/*.bats`** — see actual test code style for OS-segmented suites. We haven't viewed these yet.
2. **`.github/workflows/test.yaml`** — the `changes` job uses `git diff --name-only` against base ref to set `should_test=true/false`, gating the heavier test matrix. Worth borrowing.
3. **Their `Makefile` test wiring** — fully view how bats gets invoked across local + CI + docker.
4. **`bats_load_library` mechanism** — how shunk031 loads companion libs (vs our vendoring approach). May simplify if mise can install bats-assert too.

## Open design questions (deferred)

### Section 3 — CI workflow refactor (not yet designed)

- **Composite actions:** what shape? Candidates:
  - `.github/actions/setup-toolchain/` — installs mise + cached toolchain.
  - `.github/actions/setup-chezmoi/` — installs chezmoi + writes stub config.
  - `.github/actions/setup-apm/` — installs APM.
- **Workflow splitting:** single `ci.yaml` with composite actions, or split into `lint.yaml` / `validate.yaml` / `test.yaml`? Shunk031 splits by OS (`macos.yaml`, `ubuntu.yaml`, `remote.yaml`, `test.yaml`).
- **Caching:** `actions/cache` keys for mise data, APM modules, chezmoi binary.
- **`changes` gating job:** borrow shunk031's pattern? Skip heavy tests when only `docs/` changed.
- **Where the new `test` job lives:** runs `make test` after lint passes.

### Section 4 — CLAUDE.md documentation update

Capture the new pattern as a documented convention:

- `.chezmoitemplates/lib/` for reusable shell snippets.
- `tests/` for bats unit + template tests.
- `make test` / `make test-unit` / `make test-template` workflow.
- Pure-shell rule (no Go template syntax in lib files).

## Migration plan

### PR #10 - bats framework bootstrap

- [x] Add `.mise.toml` pinning current toolchain versions, including bats-core.
- [x] Vendor `bats-support`, `bats-assert`, and `bats-file` under `tests/test_helpers/`.
- [x] Add `tests/test_helpers/load.bash`.
- [x] Add statusline fixtures under `tests/fixtures/statusline/`.
- [x] Add `make test`, `make test-unit`, and `make test-template` targets.
- [x] Add the first bats test suite: `tests/unit/statusline.bats`.
- [x] Include bats tests in `make check`.
- [x] Open PR #10 against `main` from `feat/ci-bats`.
- [x] Confirm PR #10 CI is green.

### Remaining work after PR #10

- [ ] Read `tests/install/common/*.bats` from shunk031/dotfiles for concrete test style.
- [ ] Read `.github/workflows/test.yaml` in full from shunk031/dotfiles.
- [ ] Read shunk031's Makefile test wiring in full.
- [ ] Verify whether `bats_load_library` or mise can replace vendoring of bats-assert/file/support in a future PR.
- [ ] Design Section 3: CI workflow refactor with composite actions, caching, workflow shape, and changes gating.
- [ ] Design Section 4: CLAUDE.md documentation update.
- [ ] Extract reusable shell code from `06_install-apm.sh.tmpl` into `home/.chezmoitemplates/lib/`.
- [ ] Add bats unit tests for extracted shell libraries.
- [ ] Add template rendering tests for chezmoi/APM outputs.
- [ ] Add or revise CI jobs to run the expanded bats suite.
- [ ] Self-review the updated spec before each implementation PR.
- [ ] User reviews spec before the next migration slice.
- [ ] Hand off the next implementation slice to `writing-plans` skill.
