# CI Refactor + Shell Testing Design

**Status:** PRs #10, #12, #13, #14 merged. Library extraction + shell coverage is complete.

**Branch:** `main`

**Merged PRs:**

- [#10 Bootstrap bats framework for shell testing](https://github.com/edwinhern/dotfiles/pull/10) — mise-pinned bats-core, vendored companion libs, statusline tests, `make test` targets.
- [#12 Refactor CI setup with composite action and APM audit](https://github.com/edwinhern/dotfiles/pull/12) — `write-chezmoi-config` composite action, mise-managed APM, `apm audit --ci --no-drift --no-policy` step, dedicated `test` job, workflow-level concurrency.
- [#13 Adopt native tool configs for lint/format](https://github.com/edwinhern/dotfiles/pull/13) — `.shellcheckrc`, `.prettierignore`, `taplo.toml`, `.editorconfig` with `shell_variant = bash`; slim wrapper scripts; IDE-extension parity with CI.
- [#14 Extract APM install library with shell coverage](https://github.com/edwinhern/dotfiles/pull/14) - `lib/install/apm.sh`, Darwin-gated template injection, direct APM bats tests, and shebang coverage for the rendered run script.

**Reference:** [shunk031/dotfiles](https://github.com/shunk031/dotfiles) — pattern source.

## Context

Original `.github/workflows/ci.yaml` friction (PR #12 resolved items 1, 2, 5; PR #13 collapsed config drift across tools; PR #10 pinned toolchain):

1. ~~Duplicated chezmoi-config stub heredoc across `validate_apm` and `chezmoi_dry_run` jobs.~~ (resolved in PR #12)
2. ~~Inline `cp` plumbing in `validate_apm` re-implements parts of `chezmoi apply` manually.~~ (intentionally retained per PR #12 design — the rendered `$HOME/.apm` shape is what the dotfiles actually deploy; audit replays validate it)
3. No caching of mise/chezmoi/APM binaries — every CI run re-downloads via `curl`. (still open; caching deferred per Section 3 design)
4. One monolithic workflow with four jobs of mixed concerns. (deferred — splitting deferred until duplication is fully extracted)
5. ~~Ad-hoc `curl | sh` installs of chezmoi and APM repeated across jobs.~~ (APM resolved in PR #12 via mise; chezmoi `curl | sh` removal queued for a follow-up now that PR #14 pins chezmoi via mise)

**Primary goal:** maintainability / best practices. Secondary goal: better coverage via shell-level unit tests. Speed is fine as-is.

## Decisions made so far

### 1. Library structure (Approach 1 — approved, implemented)

Reusable shell snippets live in `home/.chezmoitemplates/lib/` so chezmoi can inject them into `.chezmoiscripts/` via `{{ template "..." . }}`. Files are pure shell (no Go template syntax), making them sourceable and testable in isolation.

```
home/.chezmoitemplates/lib/
├── common/                       # OS-agnostic helpers
│   ├── log.sh                    # log_info, log_warn, log_error  (✅ shipped in PR #14)
│   ├── error.sh                  # die, retry, with_timeout       (deferred until a caller needs it)
│   └── os-detect.sh              # is_darwin, is_linux, has_command (deferred until a caller needs it)
├── darwin/                       # macOS-specific (deferred)
│   └── homebrew.sh               # brew_install_if_missing
└── install/                      # cross-cutting install routines
    ├── apm.sh                    # apm_install_main (✅ shipped in PR #14)
    └── chezmoi.sh                # chezmoi_install_if_missing (deferred until a caller needs it)
```

**YAGNI policy for the lib:** add a primitive only when a `.chezmoiscripts/*.tmpl` script actually needs it. `log.sh` and `install/apm.sh` land first because `run_onchange_06_install-apm.sh.tmpl` is the caller. `error.sh` / `os-detect.sh` / `homebrew.sh` etc. stay deferred because they have zero current callers and would be dead code on landing.

Consuming `.chezmoiscripts/*.tmpl` files pull in lib content inside their OS guard via:

```go-template
{{ if eq .chezmoi.os "darwin" }}
{{ template "lib/common/log.sh" . }}
{{ template "lib/install/apm.sh" . }}
{{ end }}
```

**Rationale:** mirrors chezmoi's own `.chezmoiscripts/{darwin,linux,windows}/` convention; OS separation is forward-looking even though only darwin exists today; pure-shell library files are unit-testable.

**Gotcha discovered during the library-extraction PR:** Go templates parse `{{ }}` regardless of host language. Putting a literal `{{ template "lib/common/log.sh" . }}` in a _shell comment_ inside `log.sh` causes infinite recursion at render time. Document template-injection usage in plain prose, not by mirroring the directive.

### 2. Testing setup

**Toolchain (pinned via `mise.toml`):**

- `bats-core` — test runner.
- `bats-support`, `bats-assert`, `bats-file` — vendored under `tests/test_helpers/` (~100 KB total, no network dependency at test time).
- `chezmoi` — pinned in PR #14 so `tests/template/` tests render without an external install.

**Layout:**

```
tests/
├── test_helpers/                 # vendored bats companion libs + load.bash
├── unit/
│   ├── lib/common/log.bats       # ✅ shipped in PR #14 (9 tests)
│   ├── lib/install/apm.bats       # ✅ shipped in PR #14 (2 tests)
│   ├── statusline.bats           # tests/integration for home/dot_claude/statusline-command.sh (4 tests)
│   └── write-chezmoi-config.bats # ✅ shipped in PR #14 (7 tests, covers personal/work/invalid)
├── template/
│   └── install-apm-script.bats   # ✅ shipped in PR #14 (8 tests, renders + asserts lib injection)
└── fixtures/
    └── statusline/{full-payload,minimal,worktree}.json
```

**Make targets:**

```makefile
test:           mise exec -- bats --recursive tests/unit tests/template
test-unit:      mise exec -- bats --recursive tests/unit
test-template:  mise exec -- bats --recursive tests/template
```

`make check` runs `lint`, `validate`, and `test` in sequence.

### 3. `mise.toml` — single source of truth for tool versions

```toml
[tools]
"github:microsoft/apm" = "0.13.0"
bats = "1.13.0"
chezmoi = "2.70.3"           # ✅ added in PR #14 (enables template tests)
prettier = "3.8.3"
shellcheck = "0.11.0"
shfmt = "3.13.1"
taplo = "0.10.0"
```

Pinning chezmoi here also unblocks a follow-up: the `Install chezmoi` `curl | sh` step in `validate_apm` and `chezmoi_dry_run` can be removed since `mise-action` will provide chezmoi automatically.

## Patterns to study from shunk031/dotfiles

Resume by reading these in their repo if/when the next slice needs them:

1. `tests/install/common/*.bats` — concrete OS-segmented test code style.
2. `.github/workflows/test.yaml` — `changes` job using `git diff --name-only` against base ref to gate heavier matrix.
3. Their `Makefile` test wiring.
4. `bats_load_library` mechanism — would replace vendoring of bats-assert/file/support if mise gains a plugin for them.

## Section 3 — CI workflow refactor (implemented in PR #12)

See PR #12 for the implemented design. Summary:

- `.github/actions/write-chezmoi-config/` composite action with `context` input.
- `mise.toml`-managed APM (`mise exec -- apm install --dry-run --global`).
- `apm audit --ci --no-drift --no-policy` against a scratch project.
- Dedicated `test` job running `make test`.
- Workflow-level `concurrency` block cancelling superseded runs.

### Section 3 follow-ups (still open)

- Remove `curl | sh` chezmoi installs from `validate_apm` and `chezmoi_dry_run` now that chezmoi is pinned via mise. (~3-line PR)
- Split `ci.yaml` into `lint.yaml`, `validate.yaml`, `test.yaml` once a second source of duplication appears. (deferred — single workflow with composites is fine for current shape)
- Add `dorny/paths-filter@v3` change gating so `docs/`-only PRs skip APM/chezmoi jobs. (deferred — CI is fast enough)
- Add caching for mise tools and APM modules after measuring repeated setup time.
- Decide whether SARIF audit reports or `apm-policy.yml` governance are needed.

## Section 4 — CLAUDE.md documentation update (deferred)

Capture the new patterns as documented conventions in `home/dot_claude/CLAUDE.md`:

- `.chezmoitemplates/lib/` for reusable shell snippets (pure shell; injected via `{{ template }}`).
- `tests/` for bats unit + template tests; `tests/test_helpers/load.bash` as the single loader.
- `make test` / `make test-unit` / `make test-template` workflow.
- Native tool configs (`.shellcheckrc`, `.prettierignore`, `taplo.toml`, `.editorconfig`) are the source of truth; wrapper scripts in `scripts/` are thin orchestrators.
- YAGNI rule for `lib/` primitives: add only when a caller needs it.

## Migration plan

### PR #10 — bats framework bootstrap (merged)

- [x] Add `mise.toml` pinning toolchain (APM, bats-core, prettier, shellcheck, shfmt, taplo).
- [x] Vendor `bats-support`, `bats-assert`, `bats-file` under `tests/test_helpers/`.
- [x] Add `tests/test_helpers/load.bash`.
- [x] Add statusline fixtures under `tests/fixtures/statusline/`.
- [x] Add `make test`, `make test-unit`, `make test-template` targets.
- [x] Add `tests/unit/statusline.bats`.
- [x] Include bats tests in `make check`.

### PR #12 — CI setup refactor (merged)

- [x] Add `.github/actions/write-chezmoi-config/action.yml` with a `context` input.
- [x] Replace duplicated chezmoi config heredocs in `validate_apm` and `chezmoi_dry_run`.
- [x] Remove manual APM `curl` install from CI.
- [x] Run APM commands through mise.
- [x] Keep rendered `$HOME/.apm` project setup unchanged.
- [x] Keep `apm install --dry-run --global` for the initial refactor.
- [x] Add baseline `apm audit --ci --no-drift --no-policy` after the rendered APM project is prepared.
- [x] Add a dedicated `test` job that runs `make test`.
- [x] Add workflow-level concurrency cancelling superseded runs.
- [x] Co-locate `write-chezmoi-config.sh` next to its composite action.

### PR #13 — native tool configs for lint/format (merged)

- [x] Add `.shellcheckrc` with `shell=bash`, `external-sources=true`.
- [x] Extend `.editorconfig` with `shell_variant = bash` for `*.sh`, `*.zsh`, `*.bash`, `.zshrc`, `.bashrc`, etc.
- [x] Add `.prettierignore` (covers `tests/test_helpers/`, `*.tmpl`, `apm.lock.yaml`).
- [x] Add `taplo.toml` (include/exclude globs).
- [x] Slim `scripts/lint.sh` and `scripts/format.sh` (drop tool-specific flag soup).

### PR #14 - library extraction + shell coverage (merged)

- [x] Add `home/.chezmoitemplates/lib/common/log.sh` (`log_info`, `log_warn`, `log_error`).
- [x] Add `home/.chezmoitemplates/lib/install/apm.sh` with executable bash script shape and `apm_install_main`.
- [x] Refactor `run_onchange_06_install-apm.sh.tmpl` to inject `lib/common/log.sh` and `lib/install/apm.sh` inside the Darwin gate.
- [x] Add `tests/unit/lib/common/log.bats` (9 tests covering stdout/stderr routing, prefixes, special chars).
- [x] Add `tests/unit/lib/install/apm.bats` with fake `apm` on `PATH`.
- [x] Add `tests/unit/write-chezmoi-config.bats` (7 tests covering personal/work/invalid contexts and re-runs).
- [x] Add `tests/template/install-apm-script.bats` (8 tests; verifies lib injection, Darwin rendering, shebang, and rendered-script bash syntax).
- [x] Pin `chezmoi = "2.70.3"` in `mise.toml` so template tests run anywhere with mise.
- [x] Extend `scripts/lint.sh` and `scripts/format.sh` find scopes to `home/.chezmoitemplates/`.

### Later PRs

- [ ] Remove `curl | sh` chezmoi installs from CI workflow now that chezmoi is in `mise.toml`. (~3-line PR)
- [ ] Design Section 4: CLAUDE.md documentation update (capture new patterns from PRs #10–#N).
- [ ] Decide whether APM Action features are needed: SARIF, pack/restore, token forwarding, or bundle restore.
- [ ] Decide whether this repo needs `apm audit --ci --policy org` and an `apm-policy.yml` governance layer.
- [ ] Extend statusline coverage if hand-styled formatting is reformatted to canonical shfmt (currently out of lint scope to preserve the file).
- [ ] Split CI workflows or add changes gating after duplication grows again.
- [ ] Add caching for mise tools and APM modules after measuring repeated setup time.
- [ ] Verify whether `bats_load_library` or a future mise plugin can replace vendoring of bats companion libs.
- [ ] Read `tests/install/common/*.bats` from shunk031/dotfiles for concrete test style.
- [ ] Read `.github/workflows/test.yaml` in full from shunk031/dotfiles.
- [ ] Read shunk031's Makefile test wiring in full.
