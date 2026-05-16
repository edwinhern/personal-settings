# Planning Workflow Design

**Status:** Approved for implementation.

**Branch:** `main`

## Context

This repository now uses Superpowers specs and plans for design and implementation work. The older `docs/PROGRESS.md` file predates that workflow and now duplicates or conflicts with merged PR history, GitHub PR state, and the current Superpowers docs.

The repo has GitHub Issues enabled, no issue templates, no milestones, and two empty untitled user projects. GitHub Projects access is available through `gh` after refreshing auth with project scope.

## Goal

Create one planning workflow that gives a visual board for active work while keeping specs and implementation plans in the repository.

## Non-Goals

- Do not keep a long-lived local backlog in `docs/`.
- Do not migrate merged PR history into issues unless it is needed for unfinished follow-up work.
- Do not delete existing user projects unless explicitly requested.

## Recommended Approach

Use GitHub Issues as the source of truth for work items and one GitHub Project named `dotfiles` as the visual planning board.

This matches the lowest-overhead solo developer setup: Issues are the task list, and the Project is a Kanban board. Superpowers docs remain in-repo artifacts for deeper design and implementation details.

## Components

### GitHub Issues

Each feature, bug, cleanup, or research item starts as an issue. Issues should be small enough to close with one PR or with a short series of linked PRs.

Core labels:

- `bug`
- `enhancement`
- `documentation`
- `priority:high`

Area labels:

- `area:apm`
- `area:chezmoi`
- `area:ci`
- `area:docs`
- `area:agents`
- `area:editor`

The existing default labels can remain. New labels should be added only when they make filtering useful.

### GitHub Project

Create a new user project named `dotfiles` and leave the existing empty untitled projects untouched unless the user asks to remove or rename them.

Fields:

- `Status`: Backlog, In progress, Done
- `Priority`: High, Normal, Low
- `Area`: APM, Chezmoi, CI, Docs, Agents, Editor

Views:

- `Backlog`: all open issues grouped by status
- `Active`: In progress work
- `By area`: open issues grouped by area
- `Done`: recently completed work

### opencode Permissions

`home/dot_config/opencode/opencode.jsonc` should allow targeted `gh` commands for issue, label, and project management so agents can maintain the tracker without repeated prompts.

Allowed project operations are create, link, field creation, item add, and item edit. Destructive project operations should remain ask or deny.

### Superpowers Docs

`docs/superpowers/specs/` stores approved designs. `docs/superpowers/plans/` stores implementation plans created from specs.

These files are tracked supporting artifacts, not the backlog. Task issues require a linked Superpowers spec or plan before implementation starts.

### `docs/PROGRESS.md`

Replace `docs/PROGRESS.md` with a short pointer to the new workflow or archive its still-useful information into issues and specs before removal.

Recommended final state: remove `docs/PROGRESS.md` after any unfinished items are captured as GitHub issues.

## Workflow

1. Capture the idea as a GitHub issue.
2. Add the relevant core label and area label.
3. Add the issue to the `dotfiles` project.
4. Set status and priority in the project.
5. For ambiguous or larger work, write a spec under `docs/superpowers/specs/` and link it from the issue.
6. For ready work, write a plan under `docs/superpowers/plans/` and link it from the issue.
7. Implement on a branch and link the PR with `Closes #<issue>` or `Fixes #<issue>` in the PR body.
8. Let GitHub close the issue from the merged PR, then confirm the project item is Done.

## Migration

Initial migration should be small:

- Create the `dotfiles` GitHub Project.
- Add area labels and `priority:high`.
- Add issue templates for bugs and general tasks. The task template requires a linked Superpowers spec or plan.
- Add opencode permissions for issue, label, and project management.
- Convert unfinished items from `docs/PROGRESS.md` and the CI refactor spec into issues.
- Remove `docs/PROGRESS.md` once unfinished work is captured elsewhere.

Potential initial issues:

- Remove remaining `curl | sh` chezmoi installs from CI.
- Decide whether mise tool caching is worth adding to CI.
- Decide whether docs-only PRs should skip heavier checks.
- Decide whether SARIF audit reports or `apm-policy.yml` governance are needed.
- Capture current Superpowers workflow conventions in the Claude instructions if still useful.

## Error Handling

If `gh project` commands fail due to scopes, refresh auth with `gh auth refresh -s project -s read:project` and retry.

If project field automation is hard to script reliably, create the project and labels through `gh`, then finish field and view setup in the GitHub UI.

If a `docs/PROGRESS.md` item is clearly complete or superseded, do not create an issue for it.

## Verification

Verify the setup with:

- `gh issue list --repo edwinhern/dotfiles --state open --limit 20`
- `gh label list --repo edwinhern/dotfiles --limit 100`
- `gh project list --owner edwinhern --format json --limit 20`
- `mise lint`

The work is complete when the repo has no stale local backlog, open work is represented by issues, and the project board provides the visual status view.
