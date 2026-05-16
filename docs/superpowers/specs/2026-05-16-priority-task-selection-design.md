# Priority Task Selection Design

**Status:** Approved for implementation.

**Issue:** [#26](https://github.com/edwinhern/dotfiles/issues/26)

## Goal

Agents should choose the next issue from the `dotfiles` GitHub Project by priority instead of guessing from issue order.

## Priority Source

The GitHub Project `Priority` field is the sorting source of truth.

The task issue template also asks for priority so new issues capture intent before an agent sets the Project field. If the issue body and Project field differ, the Project field wins.

## Levels

- `High`: security, reproducibility, broken workflow, or work that unlocks important follow-up work.
- `Normal`: useful cleanup, maintenance, or decision work with clear value but no current breakage.
- `Low`: speculative, optional, or only worth doing when current pain appears.

Story points are not part of this workflow. If effort matters, capture it in the issue discussion or Superpowers plan for that single task.

## Selection Rule

When starting work:

1. Inspect open `Todo` items in the `dotfiles` Project.
2. Choose `High` before `Normal`, and `Normal` before `Low`.
3. If priorities tie, choose security and reproducibility work first, then blockers, then the smallest clear issue.
4. If priority is missing, set it or ask one question before implementation starts.
5. Move the selected issue to `In Progress`.
6. Link the related Superpowers spec or plan before code changes.

## Initial Backlog Priorities

- `#19 Remove curl-installed chezmoi from CI`: `High`
- `#18 Design Bitwarden-backed APM secrets handling`: `High`
- `#17 Decide APM audit governance needs`: `Normal`
- `#22 Evaluate reducing the lint toolchain`: `Normal`
- `#20 Evaluate mise tool caching in CI`: `Low`
- `#21 Evaluate docs-only CI gating`: `Low`
- `#16 Decide whether a business APM package is needed`: `Low`

## Repo Changes

- Update `AGENTS.md` with the task selection rule.
- Add a required `Priority` dropdown to `.github/ISSUE_TEMPLATE/task.yml`.
- Set priorities on current open project issues.
