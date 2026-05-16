# Planning Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make GitHub Issues the source of truth for tracked work and use a GitHub Project as the simple Kanban board for this repo.

**Architecture:** Repo instructions tell agents how to handle work items, thoughts, specs, plans, and PR links. GitHub labels, issue templates, and a `dotfiles` project provide the live tracking surface. `docs/superpowers/` stores linked specs and plans, but `docs/` is not the backlog.

**Tech Stack:** Markdown, GitHub Issues, GitHub Projects, `gh`, mise linting.

---

## File Structure

- Modify `AGENTS.md`: add the planning source-of-truth rule and the agent workflow.
- Modify `home/dot_config/opencode/opencode.jsonc`: allow targeted `gh` issue, label, and project commands.
- Create `.github/ISSUE_TEMPLATE/bug_report.md`: small bug template.
- Create `.github/ISSUE_TEMPLATE/task.yml`: required Superpowers doc link for feature, enhancement, cleanup, or research work.
- Delete `docs/PROGRESS.md`: remove the stale local backlog.
- Use `gh`: create labels, create the `dotfiles` project, and seed current follow-up issues.

### Task 1: Update Agent Instructions

**Files:**

- Modify: `AGENTS.md`

- [ ] **Step 1: Add a Planning Workflow section**

Add a section that says GitHub Issues are the source of truth, the GitHub Project is the visual Kanban board, and `docs/` is not the backlog.

- [ ] **Step 2: Add agent rules for thoughts and plans**

Specify that agents should capture new work as issues, link specs and plans from issues, and use closing keywords in PR bodies.

- [ ] **Step 3: Review wording**

Confirm the file still says `CLAUDE.md` points at `AGENTS.md` and that all providers can read the same repo instructions.

### Task 2: Add Issue Templates

**Files:**

- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/task.yml`

- [ ] **Step 1: Create the issue template directory**

Run: `mkdir .github/ISSUE_TEMPLATE`

Expected: directory exists.

- [ ] **Step 2: Add bug template**

The template should ask for summary, steps, expected behavior, actual behavior, and context.

- [ ] **Step 3: Add task issue form**

The issue form should ask for outcome, scope, area, acceptance checks, and a required linked Superpowers spec or plan.

### Task 3: Add opencode GitHub Permissions

**Files:**

- Modify: `home/dot_config/opencode/opencode.jsonc`

- [ ] **Step 1: Allow issue and label management**

Allow `gh issue edit *`, `gh issue comment *`, `gh label create *`, and `gh label edit *`.

- [ ] **Step 2: Allow project board management**

Allow `gh project list *`, `gh project view *`, `gh project field-list *`, `gh project item-list *`, `gh project create *`, `gh project link *`, `gh project field-create *`, `gh project item-add *`, and `gh project item-edit *`.

- [ ] **Step 3: Keep destructive project operations gated**

Keep project delete denied and project close, unlink, item delete, item archive, and field delete as ask.

### Task 4: Stop Tracking Work In `docs/`

**Files:**

- Delete: `docs/PROGRESS.md`

- [ ] **Step 1: Remove stale progress file**

Delete `docs/PROGRESS.md`.

- [ ] **Step 2: Keep Superpowers docs tracked**

Do not ignore or remove `docs/superpowers/` files.

### Task 5: Configure GitHub Tracking

**Tools:**

- `gh label`
- `gh project`
- `gh issue`

- [ ] **Step 1: Add labels**

Create or update `priority:high` and area labels for `apm`, `chezmoi`, `ci`, `docs`, `agents`, and `editor`.

- [ ] **Step 2: Create project**

Create a user project named `dotfiles` if one does not exist.

- [ ] **Step 3: Seed current issues**

Create issues for unfinished follow-ups that still matter:

- Remove remaining `curl | sh` chezmoi installs from CI.
- Decide whether mise tool caching is worth adding to CI.
- Decide whether docs-only PRs should skip heavier checks.
- Decide whether SARIF audit reports or `apm-policy.yml` governance are needed.
- Capture current Superpowers workflow conventions in Claude instructions if still useful.
- Design Bitwarden-backed APM secrets handling.
- Decide whether a business APM package is needed.
- Evaluate reducing the lint toolchain.

### Task 6: Verify

**Commands:**

- `mise lint`
- `gh label list --repo edwinhern/dotfiles --limit 100`
- `gh project list --owner edwinhern --format json --limit 20`
- `gh issue list --repo edwinhern/dotfiles --state open --limit 20`
- `git status --short`

- [ ] **Step 1: Run repo lint**

Expected: exit 0.

- [ ] **Step 2: Confirm GitHub setup**

Expected: labels, project, and seeded issues are visible.

- [ ] **Step 3: Confirm file changes**

Expected: only intended repo files changed or deleted.
