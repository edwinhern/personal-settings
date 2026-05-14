# Development APM Package — Progress & Next Steps

## What Was Accomplished

### `apm.yml` — Finalized

- `includes: auto` — ships local `.apm/` content alongside downloaded dependencies
- No explicit `targets:` — APM auto-detects based on harness directories present (`~/.claude/` → claude, `.github/` → copilot, etc.)
- MCP servers configured:
  - **GitHub** — `io.github.github/github-mcp-server` (`${input:github-token}` — leave as-is until Bitwarden integration)
  - **Memory** — `@modelcontextprotocol/server-memory`
  - **Sequential Thinking** — `@modelcontextprotocol/server-sequential-thinking`
  - **Filesystem** — `@modelcontextprotocol/server-filesystem`
  - **Figma** — `https://mcp.figma.com/mcp` (HTTP, Bearer token) — **work only in template**
  - **Atlassian** — `mcp-remote` to `https://mcp.atlassian.com/v1/mcp` with `--resource <URL>` — **work only in template** (Liberty Mutual Jira + Knowledge LM)

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

---

## Workflow Pipelines

### Work (JIRA ticket)

```
JIRA ticket
  → @research agent         (deep-analysis + GitHub MCP + sequential thinking → Research Summary)
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

### ✅ Step 1: Restructure into `~/.config/apm/`

Move source files into chezmoi `home/` under `.config/apm/` to keep root clean:

```
dotfiles/home/dot_config/apm/
  apm.yml.tmpl              →  ~/.config/apm/apm.yml
  dot_apm/                  →  ~/.config/apm/.apm/
    agents/
    instructions/
    skills/
```

APM reads `apm.yml` from the working directory — running `cd ~/.config/apm && apm install` works correctly. The `~/.apm/` that already exists is APM's internal cache (separate, no conflict).

### ✅ Step 2: Create `apm.yml.tmpl` — Work-Only MCP Servers

The template's only variation is Figma and Atlassian, which only appear when `work: true`:

```yaml
# apm.yml.tmpl
name: development
version: 1.0.0
description: APM project for development
author: Edwin Hernandez
includes: auto
dependencies:
  apm:
    - obra/superpowers
    - anthropics/claude-plugins-official/plugins/skill-creator
  mcp:
    - name: io.github.github/github-mcp-server
      env:
        GITHUB_PERSONAL_ACCESS_TOKEN: "${input:github-token}"
    - name: memory
      registry: false
      transport: stdio
      command: npx
      args: ["-y", "@modelcontextprotocol/server-memory"]
    - name: sequential-thinking
      registry: false
      transport: stdio
      command: npx
      args: ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    - name: filesystem
      registry: false
      transport: stdio
      command: npx
      args: ["-y", "@modelcontextprotocol/server-filesystem", "${input:github-root-directory}"]
{{- if .work }}
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
      args: ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/mcp", "--resource", "{{ .atlassian_resource_url }}"]
{{- end }}
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
# apm.yml:       {{ include "dot_config/apm/apm.yml.tmpl" | sha256sum }}
# agents:        {{ range (glob (printf "%s/dot_config/apm/dot_apm/agents/*" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}
# instructions:  {{ range (glob (printf "%s/dot_config/apm/dot_apm/instructions/*" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}
# skills:        {{ range (glob (printf "%s/dot_config/apm/dot_apm/skills/**/*.md" $src)) }}{{ include (trimPrefix (printf "%s/" $src) .) | sha256sum }} {{ end }}

set -e
cd ~/.config/apm && apm install --runtime claude
```

**Key:** paths are relative to `.chezmoiroot` (`home/`) — no `home/` prefix. `glob` uses `.chezmoi.sourceDir` for portability across machines. Content of every agent, instruction, and skill file is hashed — content changes trigger reinstall.

### Step 4: `.agents/` Output

APM always creates `.agents/` as a cross-tool compatibility output. Since it will land at `~/.config/apm/.agents/` (not root), it stays contained. Add to `.gitignore` there. No action needed in root.

---

## Roadmap (Future)

| Item                             | Notes                                                                                                                                                                           |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Bitwarden Secret Manager CLI** | Replace `${input:github-token}` with env vars pulled from Bitwarden. Chezmoi already has Bitwarden integration — plan the secret → env var pipeline separately                  |
| ✅ **GitHub Actions CI for APM** | `validate_apm` job renders `apm.yml.tmpl` via chezmoi + runs `apm install --dry-run --runtime claude` for both personal and work contexts. All jobs green.                      |
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
| `apm.lock.yaml`         | Pinned commit hashes                 | ✓ commit to source    |

`CLAUDE.md` is **not** created by APM — manage separately.
