# CLAUDE.md

## Repository Context

- This repository is managed with [`chezmoi`](https://www.chezmoi.io/) ([GitHub](https://github.com/twpayne/chezmoi)).
- Files under `home/` are the public source state and are applied by `chezmoi` into the user's `$HOME` directory.

## Response Rule

- After reading this `CLAUDE.md`, say: `🤖 I read the CLAUDE.md for edwinhern/dotfiles.`

## Comment Policy

- When adding or updating comments for shell scripts or shell-based executables, always write them in English using shdoc-compatible format.

## Git / PR Workflow

- After pushing to GitHub, always check the GitHub Actions CI results. If CI fails, investigate the failure, fix the issue, push again, and repeat until all CI checks pass.
