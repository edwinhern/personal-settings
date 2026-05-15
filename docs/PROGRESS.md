# Development APM Package — Progress & Next Steps

## What Was Accomplished

### `apm.yml` — Finalized

- `includes: auto` — ships local `.apm/` content alongside downloaded dependencies
- Explicit `target: [claude, copilot, opencode]` — primitives deploy to all three harness directories
- MCP servers configured:
  - **Figma** — `https://mcp.figma.com/mcp` (HTTP, Bearer token) — **work only in template**
  - **Atlassian** — `mcp-remote` to `https://mcp.atlassian.com/v1/mcp` with `--resource <URL>` — **work only in template** (Liberty Mutual Jira + Knowledge LM)
- **GitHub access uses the `gh` CLI**, not the GitHub MCP server. The CLI covers issue/PR/code-search/release operations with fewer moving parts; the MCP variant was removed.
- **Memory / Sequential Thinking / Filesystem MCPs were also removed** — preference is shifting toward CLI tooling for predictable, scriptable access rather than running long-lived MCP processes.

### Agents (`.apm/agents/`)

| Agent                     | Purpose                                                                                       | Context   |
| ------------------------- | --------------------------------------------------------------------------------------------- | --------- |
| `research.agent.md`       | Read-only. JIRA ticket → deep-analysis skill → Research Summary → `superpowers:writing-plans` | Work only |
| `code-reviewer.agent.md`  | Code review: confidence filtering, React/TS patterns, false positives list                    | Both      |
| `doc-researcher.agent.md` | Explicit Context7 documentation lookups                                                       | Both      |

### Skills (`.apm/skills/`)

Custom: `context7-cli`, `deep-analysis` (with rubric + summary template), `kaizen`, `reddit-fetch`

From `obra/superpowers` (14 skills): `test-driven-development`, `subagent-driven-development`, `writing-plans`, `executing-plans`, `dispatching-parallel-agents`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `systematic-debugging`, `finishing-a-development-branch`, `using-git-worktrees`, `brainstorming`, `writing-skills`, `using-superpowers`

From `skill-creator`: eval framework for authoring new skills

### Instructions (`.apm/instructions/`)

`00-meta-rules`, `01-coding-standards`, `02-typescript-guidelines`, `03-react-guidelines`, `04-testing-guidelines`, `05-commit-guide` (JIRA format: `<type>: {TICKET_NUMBER} <description>`)

### Verified: `apm install` Works

Ran from `packages/development/`. superpowers (14 skills + session hooks), skill-creator, and local `.apm/` content all deployed correctly. `.claude/`, `.agents/`, `.github/` are gitignored in this directory (they're test artifacts — real deployment goes to `~/.config/apm/` via chezmoi).

### Verified: Superpowers Session Hook Works

Ran `~/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd session-start` with `CLAUDE_PLUGIN_ROOT` pointing at the installed superpowers package. The hook emits Claude's `hookSpecificOutput.additionalContext` JSON payload and injects the `superpowers:using-superpowers` skill content at session start.

---

## Workflow Pipelines

### Work (JIRA ticket)

```
JIRA ticket
  → @research agent         (deep-analysis + gh CLI + optional MCPs → Research Summary)
  → superpowers:writing-plans    (TDD plan: exact file paths, test code, commands)
  → superpowers:subagent-driven-development  (fresh subagent per task)
      └─ superpowers:test-driven-development (RED → GREEN → REFACTOR)
      └─ spec reviewer + code quality reviewer subagents after each task
  → superpowers:finishing-a-development-branch → PR
```

### Personal (your own idea, you are the PO)

```
Your idea
  → superpowers:brainstorming   (explore idea, break into sub-projects if large)
  → superpowers:writing-plans   (TDD plan from brainstorm output)
  → superpowers:subagent-driven-development
  → superpowers:finishing-a-development-branch → commit/PR
```

---

## Next Steps — Chezmoi Integration

### ✅ Step 1: Deploy source into `~/.apm/` (APM's native user-scope home)

APM's `--global` flag reads `apm.yml` from `~/.apm/apm.yml` and, per the [targets matrix](https://microsoft.github.io/apm/reference/targets-matrix/#claude), deploys Claude content to `CLAUDE_CONFIG_DIR` (defaults to `~/.claude/`). So chezmoi puts source files directly into APM's home:

```
dotfiles/home/dot_apm/
  apm.yml.tmpl              →  ~/.apm/apm.yml
  dot_apm/                  →  ~/.apm/.apm/
    agents/
    instructions/
    skills/
```

`apm install --global --target claude` then deploys agents/skills/rules to `~/.claude/` natively — no symlink hack, no file copying. The `apm_modules/` cache, `cache/`, `config.json`, and `marketplaces.json` files APM creates at `~/.apm/` coexist with our chezmoi-managed `apm.yml` + `.apm/`.

### ✅ Step 2: Create `apm.yml.tmpl` — Work-Only MCP Servers

Only Figma and Atlassian MCPs are configured, and both are gated behind `work: true`. Personal machines render a template with an empty `mcp:` list. The actual current state:

```yaml
# apm.yml.tmpl
name: development
version: 1.0.0
description: APM project for development
target:
  - claude
  - copilot
  - opencode
author: Edwin Hernandez
includes: auto
dependencies:
  apm:
    - obra/superpowers
    - anthropics/claude-plugins-official/plugins/skill-creator
  mcp:
{{ if .work }}
    - name: figma
      registry: false
      transport: http
      url: https://mcp.figma.com/mcp
      headers:
        Authorization: "Bearer ${input:figma-token}"

    - name: atlassian
      registry: false
      transport: stdio
      command: npx
      args:
        - "-y"
        - "mcp-remote"
        - "https://mcp.atlassian.com/v1/mcp"
        - "--resource"
        - "{{ .atlassian_resource_url }}"
{{ end }}
```

Add `atlassian_resource_url` to chezmoi data on work machines.

### ✅ Step 3: Bootstrap Script

```
dotfiles/home/.chezmoiscripts/darwin/run_onchange_06_install-apm.sh.tmpl
```

```bash
#!/bin/bash
# Reinstalls APM dependencies whenever apm.yml or .apm/ content changes.
{{- $src := .chezmoi.sourceDir }}
# apm.yml:       {{ include "dot_apm/apm.yml.tmpl" | sha256sum }}
# apm.lock.yaml: {{ include "dot_apm/apm.lock.yaml" | sha256sum }}
# agents:        {{ range (glob (printf "%s/dot_apm/dot_apm/agents/*" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}
# instructions:  {{ range (glob (printf "%s/dot_apm/dot_apm/instructions/*" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}
# skills:        {{ range (glob (printf "%s/dot_apm/dot_apm/skills/**/*.md" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}

set -e

echo "[apm] Installing globally from ~/.apm/apm.yml..."
cd ~/.apm
apm install --global || echo "[apm] apm install exited with errors (likely MCP token prompts in non-interactive shell)"

echo "[apm] Install complete."
```

**Key:** paths are relative to `.chezmoiroot` (`home/`) — no `home/` prefix. `glob` uses `.chezmoi.sourceDir` for portability across machines. Content of every agent, instruction, and skill file is hashed — content changes trigger reinstall. `apm install --global` reads `~/.apm/apm.yml`; the template's `target` list controls Claude, Copilot, and opencode deployment.

---

## Roadmap (Future)

| Item                             | Notes                                                                                                                                                                           |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bitwarden secrets pipeline**   | Replace `${input:figma-token}` and similar APM prompts with values sourced from Bitwarden. Likely shape: chezmoi-managed `private_secrets.local.tmpl` rendered with `{{ bitwardenFields ... }}`, sourced by `06_install-apm.sh` before `apm install`. Open design question: does APM honor env vars as `${input:...}` fallback? Needs dedicated brainstorm. |
| ✅ **GitHub Actions CI for APM (initial)** | `validate_apm` + `chezmoi_dry_run` jobs render `apm.yml.tmpl` via chezmoi + run `apm install --dry-run --global` for personal and work contexts. All jobs green. Refactor pending (see row below).                              |
| **CI / GitHub Actions refactor** | Current `.github/workflows/ci.yaml` has duplicated chezmoi-config stubs across jobs, inline `cp` plumbing in `validate_apm`, no caching of mise/chezmoi/APM binaries, and ad-hoc `curl` installs. Candidates: composite actions for repeated setup, `actions/cache` for binaries, splitting workflows by concern (lint vs apply vs install-test). Needs dedicated brainstorm. |
| **Business package**             | Separate `packages/business/` with its own `apm.yml` and `.apm/` for business-context agents/instructions                                                                       |
| **Reduce lint toolchain**        | Currently 4 tools: prettier, shellcheck, shfmt, taplo. `taplo` (TOML) is most optional. `shfmt` overlaps with shellcheck but handles formatting. Evaluate dropping taplo first. |

---

## What `apm install` Creates (Reference)

| Path                    | Contents                             | Keep?                 |
| ----------------------- | ------------------------------------ | --------------------- |
| `.claude/agents/`       | Your agent files                     | ✓ (target output)     |
| `.claude/rules/`        | Your instruction files               | ✓                     |
| `.claude/skills/`       | All skills (superpowers + custom)    | ✓                     |
| `.claude/settings.json` | Superpowers session hooks            | ✓                     |
| `.agents/`              | Cross-tool skill copy                | Ignore (gitignore it) |
| `.github/`              | Copilot output (if detected)         | On work machines only |
| `apm_modules/`          | Dependency cache (like node_modules) | Gitignore always      |
| `apm.lock.yaml`         | Pinned commit hashes (regenerated by APM on every install) | Tracked in source for CI seeding; listed in `home/.chezmoiignore` so chezmoi's apply pass ignores destination drift |

`CLAUDE.md` is **not** created by APM — manage separately.
