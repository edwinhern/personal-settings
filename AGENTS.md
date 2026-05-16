# AGENTS.md

## Repository Context

- This repository is managed with [`chezmoi`](https://www.chezmoi.io/) ([GitHub](https://github.com/twpayne/chezmoi)).
- Files under `home/` are the public source state and are applied by `chezmoi` into the user's `$HOME` directory.

## Response Rule

- After reading this `CLAUDE.md`, say: `🤖 I read the CLAUDE.md for edwinhern/dotfiles.`

## Comment Policy

- When adding or updating comments for shell scripts or shell-based executables, always write them in English using shdoc-compatible format.

## Planning Workflow

- GitHub Issues are the source of truth for features, bugs, enhancements, cleanup work, research, and follow-up tasks.
- The GitHub Project named `dotfiles` is the visual Kanban board for those issues.
- Use the simple board flow: `Todo`, `In Progress`, `Done`. Treat `Todo` as the backlog lane.
- Do not use `docs/` as the issue tracker, roadmap, or long-lived backlog.
- Superpowers specs and plans live under `docs/superpowers/` and should be linked from the related GitHub issue.

## Agent Work Tracking

- When new work is discovered, create or update a GitHub issue instead of adding a backlog item under `docs/`.
- Keep issues small enough to close with one PR or a short linked PR series.
- Link the relevant Superpowers spec or plan from the issue before implementation starts.
- Track active work by moving the issue in the `dotfiles` project instead of editing a progress document.
- Link PRs to issues with closing keywords in the PR body, such as `Closes #123` or `Fixes #123`.
- If a thought is not ready for an issue, keep it in the current conversation or a Superpowers spec until it becomes actionable.

## Git / PR Workflow

- After pushing to GitHub, always check the GitHub Actions CI results. If CI fails, investigate the failure, fix the issue, push again, and repeat until all CI checks pass.
